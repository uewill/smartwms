package com.clothing.erp.service;

import com.clothing.erp.dto.report.*;
import com.clothing.erp.entity.Customer;
import com.clothing.erp.entity.ProductSku;
import com.clothing.erp.repository.CustomerRepository;
import com.clothing.erp.repository.ProductSkuRepository;
import com.clothing.erp.repository.SaleOrderItemRepository;
import com.clothing.erp.repository.SaleOrderRepository;
import com.clothing.erp.util.ExcelUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.temporal.ChronoUnit;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ReportService {

    private final SaleOrderRepository saleOrderRepository;
    private final SaleOrderItemRepository saleOrderItemRepository;
    private final ProductSkuRepository productSkuRepository;
    private final CustomerRepository customerRepository;
    private final SubscriptionService subscriptionService;

    @Transactional(readOnly = true)
    public TodaySummaryVO getTodaySummary(Long shopId) {
        LocalDateTime startOfDay = LocalDate.now().atStartOfDay();
        LocalDateTime endOfDay = LocalDate.now().atTime(LocalTime.MAX);

        BigDecimal todaySales = saleOrderRepository.sumActualAmountByShopIdAndCreatedAtBetween(
                shopId, startOfDay, endOfDay);
        Long todayOrderCount = saleOrderRepository.countByShopIdAndCreatedAtBetween(
                shopId, startOfDay, endOfDay);
        BigDecimal todayCost = saleOrderRepository.sumPurchaseCostByShopIdAndCreatedAtBetween(
                shopId, startOfDay, endOfDay);

        BigDecimal todayProfit = todaySales.subtract(todayCost).setScale(2, RoundingMode.HALF_UP);

        return TodaySummaryVO.builder()
                .todaySales(todaySales)
                .todayProfit(todayProfit)
                .todayOrderCount(todayOrderCount != null ? todayOrderCount.intValue() : 0)
                .build();
    }

    @Transactional(readOnly = true)
    public List<HotProductVO> getHotProducts(Long shopId, HotProductQueryRequest request) {
        subscriptionService.validatePremium(shopId);

        LocalDateTime startTime = request.getStartDate() != null
                ? request.getStartDate().atStartOfDay()
                : LocalDate.now().minusDays(30).atStartOfDay();
        LocalDateTime endTime = request.getEndDate() != null
                ? request.getEndDate().atTime(LocalTime.MAX)
                : LocalDate.now().atTime(LocalTime.MAX);
        int top = request.getTop() != null ? request.getTop() : 20;

        List<Object[]> results = saleOrderItemRepository.findHotProductsByShopIdAndPeriod(
                shopId, startTime, endTime);

        return results.stream()
                .limit(top)
                .map(row -> HotProductVO.builder()
                        .productId(row[0] != null ? ((Number) row[0]).longValue() : null)
                        .styleNo(row[1] != null ? row[1].toString() : null)
                        .productName(row[2] != null ? row[2].toString() : null)
                        .thumbUrl(row[3] != null ? row[3].toString() : null)
                        .salesQuantity(row[4] != null ? ((Number) row[4]).intValue() : 0)
                        .salesAmount(row[5] != null ? (BigDecimal) row[5] : BigDecimal.ZERO)
                        .build())
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<OverstockVO> getOverstock(Long shopId) {
        subscriptionService.validatePremium(shopId);

        List<ProductSku> allSkus = productSkuRepository.findByShopIdWithStockFilter(
                shopId, null, null, null, null,
                PageRequest.of(0, 10000))
                .getContent();

        List<Object[]> lastSaleDates = saleOrderItemRepository.findLastSaleDateByShopId(shopId);

        Map<Long, LocalDateTime> skuLastSaleMap = new HashMap<>();
        for (Object[] row : lastSaleDates) {
            Long skuId = row[0] != null ? ((Number) row[0]).longValue() : null;
            LocalDateTime lastSaleDate = row[5] != null ? (LocalDateTime) row[5] : null;
            if (skuId != null) {
                skuLastSaleMap.put(skuId, lastSaleDate);
            }
        }

        List<OverstockVO> result = new ArrayList<>();
        for (ProductSku sku : allSkus) {
            if (sku.getStockQty() == null || sku.getStockQty() <= 0) {
                continue;
            }

            LocalDateTime lastSaleDateTime = skuLastSaleMap.get(sku.getId());
            LocalDate lastSaleDate = lastSaleDateTime != null ? lastSaleDateTime.toLocalDate() : null;

            long turnoverDays = lastSaleDate != null
                    ? ChronoUnit.DAYS.between(lastSaleDate, LocalDate.now())
                    : ChronoUnit.DAYS.between(sku.getCreatedAt().toLocalDate(), LocalDate.now());

            if (turnoverDays > 30) {
                result.add(OverstockVO.builder()
                        .skuId(sku.getId())
                        .styleNo(sku.getProduct() != null ? sku.getProduct().getStyleNo() : null)
                        .productName(sku.getProduct() != null ? sku.getProduct().getName() : null)
                        .colorName(sku.getColor() != null ? sku.getColor().getColorName() : null)
                        .sizeName(sku.getSize() != null ? sku.getSize().getSizeName() : null)
                        .stockQty(sku.getStockQty())
                        .lastSaleDate(lastSaleDate)
                        .turnoverDays((int) turnoverDays)
                        .build());
            }
        }

        result.sort(Comparator.comparingInt(OverstockVO::getTurnoverDays).reversed());
        return result;
    }

    @Transactional(readOnly = true)
    public List<CustomerDebtSummaryVO> getCustomerDebtSummary(Long shopId) {
        subscriptionService.validatePremium(shopId);

        List<Customer> debtCustomers = customerRepository.findDebtCustomersByShopId(shopId);

        return debtCustomers.stream()
                .map(customer -> CustomerDebtSummaryVO.builder()
                        .customerId(customer.getId())
                        .customerName(customer.getName())
                        .totalDebt(customer.getTotalDebt())
                        .orderCount(0)
                        .build())
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public ProfitAnalysisVO getProfitAnalysis(Long shopId, ReportQueryRequest request) {
        subscriptionService.validatePremium(shopId);

        LocalDateTime startTime = request.getStartDate() != null
                ? request.getStartDate().atStartOfDay()
                : LocalDate.now().minusDays(30).atStartOfDay();
        LocalDateTime endTime = request.getEndDate() != null
                ? request.getEndDate().atTime(LocalTime.MAX)
                : LocalDate.now().atTime(LocalTime.MAX);

        BigDecimal totalRevenue = saleOrderItemRepository.sumRevenueByShopIdAndPeriod(shopId, startTime, endTime);
        BigDecimal totalCost = saleOrderItemRepository.sumCostByShopIdAndPeriod(shopId, startTime, endTime);
        BigDecimal totalProfit = totalRevenue.subtract(totalCost).setScale(2, RoundingMode.HALF_UP);
        BigDecimal profitRate = totalRevenue.compareTo(BigDecimal.ZERO) > 0
                ? totalProfit.divide(totalRevenue, 4, RoundingMode.HALF_UP).multiply(BigDecimal.valueOf(100))
                        .setScale(2, RoundingMode.HALF_UP)
                : BigDecimal.ZERO;

        List<Object[]> dailyResults = saleOrderItemRepository.findDailyProfitByShopIdAndPeriod(
                shopId, startTime, endTime);

        List<DailyProfitVO> dailyProfits = dailyResults.stream()
                .map(row -> {
                    BigDecimal revenue = row[1] != null ? (BigDecimal) row[1] : BigDecimal.ZERO;
                    BigDecimal cost = row[2] != null ? (BigDecimal) row[2] : BigDecimal.ZERO;
                    BigDecimal profit = revenue.subtract(cost).setScale(2, RoundingMode.HALF_UP);
                    return DailyProfitVO.builder()
                            .date(row[0] != null ? row[0].toString() : null)
                            .revenue(revenue)
                            .cost(cost)
                            .profit(profit)
                            .build();
                })
                .collect(Collectors.toList());

        return ProfitAnalysisVO.builder()
                .totalRevenue(totalRevenue)
                .totalCost(totalCost)
                .totalProfit(totalProfit)
                .profitRate(profitRate)
                .dailyProfits(dailyProfits)
                .build();
    }

    @Transactional(readOnly = true)
    public byte[] exportHotProducts(Long shopId, HotProductQueryRequest request) throws IOException {
        List<HotProductVO> hotProducts = getHotProducts(shopId, request);

        List<String> headers = Arrays.asList("排名", "款号", "商品名称", "销售数量", "销售金额");
        List<List<Object>> data = new ArrayList<>();
        int rank = 1;
        for (HotProductVO vo : hotProducts) {
            data.add(Arrays.asList(rank++, vo.getStyleNo(), vo.getProductName(),
                    vo.getSalesQuantity(), vo.getSalesAmount()));
        }

        return ExcelUtil.generateExcel(headers, data);
    }

    @Transactional(readOnly = true)
    public byte[] exportCustomerDebt(Long shopId) throws IOException {
        List<CustomerDebtSummaryVO> debts = getCustomerDebtSummary(shopId);

        List<String> headers = Arrays.asList("客户名称", "欠款总额");
        List<List<Object>> data = new ArrayList<>();
        for (CustomerDebtSummaryVO vo : debts) {
            data.add(Arrays.asList(vo.getCustomerName(), vo.getTotalDebt()));
        }

        return ExcelUtil.generateExcel(headers, data);
    }

    @Transactional(readOnly = true)
    public byte[] exportProfitAnalysis(Long shopId, ReportQueryRequest request) throws IOException {
        ProfitAnalysisVO analysis = getProfitAnalysis(shopId, request);

        List<String> headers = Arrays.asList("日期", "收入", "成本", "利润");
        List<List<Object>> data = new ArrayList<>();
        for (DailyProfitVO vo : analysis.getDailyProfits()) {
            data.add(Arrays.asList(vo.getDate(), vo.getRevenue(), vo.getCost(), vo.getProfit()));
        }

        return ExcelUtil.generateExcel(headers, data);
    }
}
