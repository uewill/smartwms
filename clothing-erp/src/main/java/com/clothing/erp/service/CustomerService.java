package com.clothing.erp.service;

import com.clothing.erp.common.ErrorCode;
import com.clothing.erp.dto.customer.*;
import com.clothing.erp.entity.*;
import com.clothing.erp.exception.BusinessException;
import com.clothing.erp.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CustomerService {

    private final CustomerRepository customerRepository;
    private final CustomerPriceRepository customerPriceRepository;
    private final SaleOrderRepository saleOrderRepository;
    private final PaymentRecordRepository paymentRecordRepository;
    private final PaymentAllocationRepository paymentAllocationRepository;
    private final ShopRepository shopRepository;
    private final SubscriptionRepository subscriptionRepository;

    @Transactional
    public CustomerVO createCustomer(Long shopId, CreateCustomerRequest request) {
        Shop shop = shopRepository.findById(shopId)
                .orElseThrow(() -> new BusinessException(ErrorCode.SHOP_NOT_FOUND));

        Customer customer = new Customer();
        customer.setShop(shop);
        customer.setName(request.getName());
        customer.setPhone(request.getPhone());
        customer.setRemark(request.getRemark());
        customer.setTotalDebt(BigDecimal.ZERO);

        Customer saved = customerRepository.save(customer);
        return toCustomerVO(saved);
    }

    @Transactional
    public CustomerVO updateCustomer(Long shopId, Long customerId, CreateCustomerRequest request) {
        Customer customer = customerRepository.findByIdAndShopId(customerId, shopId)
                .orElseThrow(() -> new BusinessException(ErrorCode.CUSTOMER_NOT_FOUND));

        customer.setName(request.getName());
        customer.setPhone(request.getPhone());
        customer.setRemark(request.getRemark());

        Customer saved = customerRepository.save(customer);
        return toCustomerVO(saved);
    }

    @Transactional(readOnly = true)
    public CustomerVO getCustomer(Long shopId, Long customerId) {
        Customer customer = customerRepository.findByIdAndShopId(customerId, shopId)
                .orElseThrow(() -> new BusinessException(ErrorCode.CUSTOMER_NOT_FOUND));
        return toCustomerVO(customer);
    }

    @Transactional(readOnly = true)
    public Page<CustomerVO> listCustomers(Long shopId, CustomerQueryRequest query) {
        Pageable pageable = PageRequest.of(query.getPage(), query.getSize());
        Page<Customer> page = customerRepository.findByShopIdWithKeyword(shopId, query.getKeyword(), pageable);
        return page.map(this::toCustomerVO);
    }

    @Transactional
    public void deleteCustomer(Long shopId, Long customerId) {
        Customer customer = customerRepository.findByIdAndShopId(customerId, shopId)
                .orElseThrow(() -> new BusinessException(ErrorCode.CUSTOMER_NOT_FOUND));

        if (customer.getTotalDebt().compareTo(BigDecimal.ZERO) > 0) {
            throw new BusinessException(ErrorCode.CUSTOMER_HAS_DEBT);
        }

        customerPriceRepository.deleteByCustomerId(customerId);
        customerRepository.delete(customer);
    }

    @Transactional
    public PaymentRecordVO collectDebt(Long shopId, Long userId, CollectDebtRequest request) {
        Customer customer = customerRepository.findByIdAndShopId(request.getCustomerId(), shopId)
                .orElseThrow(() -> new BusinessException(ErrorCode.CUSTOMER_NOT_FOUND));

        if (request.getAmount().compareTo(BigDecimal.ZERO) <= 0) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "还款金额必须大于0");
        }

        if (request.getAmount().compareTo(customer.getTotalDebt()) > 0) {
            throw new BusinessException(ErrorCode.DEBT_AMOUNT_EXCEED);
        }

        Shop shop = shopRepository.findById(shopId)
                .orElseThrow(() -> new BusinessException(ErrorCode.SHOP_NOT_FOUND));

        PaymentRecord paymentRecord = new PaymentRecord();
        paymentRecord.setShop(shop);
        paymentRecord.setCustomer(customer);
        paymentRecord.setAmount(request.getAmount());
        paymentRecord.setRemark(request.getRemark());

        List<SaleOrder> creditOrders = saleOrderRepository.findByCustomerIdAndPaymentMethodCredit(
                customer.getId(), SaleOrder.SaleOrderType.SALE);

        List<Long> orderIds = creditOrders.stream().map(SaleOrder::getId).toList();
        Map<Long, BigDecimal> paidMap = buildPaidAmountMap(orderIds);

        BigDecimal remaining = request.getAmount();
        List<PaymentAllocation> allocations = new ArrayList<>();

        for (SaleOrder order : creditOrders) {
            if (remaining.compareTo(BigDecimal.ZERO) <= 0) {
                break;
            }

            BigDecimal paid = paidMap.getOrDefault(order.getId(), BigDecimal.ZERO);
            BigDecimal unpaid = order.getActualAmount().subtract(paid);

            if (unpaid.compareTo(BigDecimal.ZERO) <= 0) {
                continue;
            }

            BigDecimal toAllocate = remaining.min(unpaid);

            PaymentAllocation allocation = new PaymentAllocation();
            allocation.setPayment(paymentRecord);
            allocation.setOrder(order);
            allocation.setAllocatedAmount(toAllocate);
            allocations.add(allocation);

            remaining = remaining.subtract(toAllocate);
        }

        paymentRecord.setAllocations(allocations);
        PaymentRecord saved = paymentRecordRepository.save(paymentRecord);

        customer.setTotalDebt(customer.getTotalDebt().subtract(request.getAmount()));
        customerRepository.save(customer);

        return toPaymentRecordVO(saved);
    }

    @Transactional(readOnly = true)
    public CustomerDebtDetailVO getDebtDetail(Long shopId, Long customerId) {
        Customer customer = customerRepository.findByIdAndShopId(customerId, shopId)
                .orElseThrow(() -> new BusinessException(ErrorCode.CUSTOMER_NOT_FOUND));

        List<SaleOrder> creditOrders = saleOrderRepository.findByCustomerIdAndPaymentMethodCredit(
                customer.getId(), SaleOrder.SaleOrderType.SALE);

        List<Long> orderIds = creditOrders.stream().map(SaleOrder::getId).toList();
        Map<Long, BigDecimal> paidMap = buildPaidAmountMap(orderIds);

        List<DebtSaleOrderVO> unpaidOrders = creditOrders.stream()
                .filter(order -> {
                    BigDecimal paid = paidMap.getOrDefault(order.getId(), BigDecimal.ZERO);
                    return order.getActualAmount().subtract(paid).compareTo(BigDecimal.ZERO) > 0;
                })
                .map(order -> {
                    BigDecimal paid = paidMap.getOrDefault(order.getId(), BigDecimal.ZERO);
                    return DebtSaleOrderVO.builder()
                            .orderId(order.getId())
                            .orderNo(order.getOrderNo())
                            .actualAmount(order.getActualAmount())
                            .unpaidAmount(order.getActualAmount().subtract(paid))
                            .createdAt(order.getCreatedAt())
                            .build();
                })
                .toList();

        List<PaymentRecord> records = paymentRecordRepository.findByCustomerIdOrderByCreatedAtDesc(customer.getId());
        List<PaymentRecordVO> paymentRecordVOs = records.stream()
                .map(this::toPaymentRecordVO)
                .toList();

        return CustomerDebtDetailVO.builder()
                .customerInfo(toCustomerVO(customer))
                .unpaidOrders(unpaidOrders)
                .paymentRecords(paymentRecordVOs)
                .build();
    }

    @Transactional(readOnly = true)
    public StatementVO generateStatement(Long shopId, StatementRequest request) {
        Subscription subscription = subscriptionRepository
                .findByShopIdAndStatus(shopId, Subscription.SubscriptionStatus.ACTIVE)
                .orElse(null);

        if (subscription == null || subscription.getPlanType() != Subscription.PlanType.PREMIUM) {
            throw new BusinessException(ErrorCode.PREMIUM_REQUIRED);
        }

        Customer customer = customerRepository.findByIdAndShopId(request.getCustomerId(), shopId)
                .orElseThrow(() -> new BusinessException(ErrorCode.CUSTOMER_NOT_FOUND));

        LocalDateTime periodStart = request.getStartDate().atStartOfDay();
        LocalDateTime periodEnd = request.getEndDate().atTime(LocalTime.MAX);

        BigDecimal creditBeforePeriod = saleOrderRepository.sumCreditAmountBefore(customer.getId(), periodStart);

        BigDecimal paymentBeforePeriod = paymentRecordRepository.sumPaymentAmountByCustomerIdBefore(
                customer.getId(), periodStart);

        BigDecimal openingDebt = creditBeforePeriod.subtract(paymentBeforePeriod);
        if (openingDebt.compareTo(BigDecimal.ZERO) < 0) {
            openingDebt = BigDecimal.ZERO;
        }

        List<SaleOrder> creditOrders = saleOrderRepository.findCreditOrdersByCustomerIdAndPeriod(
                customer.getId(), periodStart, periodEnd);

        List<Long> orderIds = creditOrders.stream().map(SaleOrder::getId).toList();
        Map<Long, BigDecimal> paidMap = buildPaidAmountMap(orderIds);

        List<DebtSaleOrderVO> creditOrderVOs = creditOrders.stream()
                .map(order -> {
                    BigDecimal paid = paidMap.getOrDefault(order.getId(), BigDecimal.ZERO);
                    return DebtSaleOrderVO.builder()
                            .orderId(order.getId())
                            .orderNo(order.getOrderNo())
                            .actualAmount(order.getActualAmount())
                            .unpaidAmount(order.getActualAmount().subtract(paid))
                            .createdAt(order.getCreatedAt())
                            .build();
                })
                .toList();

        BigDecimal totalCredit = creditOrders.stream()
                .map(SaleOrder::getActualAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        List<PaymentRecord> periodPayments = paymentRecordRepository
                .findByCustomerIdAndCreatedAtBetween(customer.getId(), periodStart, periodEnd);
        List<PaymentRecordVO> periodPaymentVOs = periodPayments.stream()
                .map(this::toPaymentRecordVO)
                .toList();

        BigDecimal totalPayment = periodPaymentVOs.stream()
                .map(PaymentRecordVO::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal closingDebt = openingDebt.add(totalCredit).subtract(totalPayment);
        if (closingDebt.compareTo(BigDecimal.ZERO) < 0) {
            closingDebt = BigDecimal.ZERO;
        }

        return StatementVO.builder()
                .customerInfo(toCustomerVO(customer))
                .startDate(request.getStartDate())
                .endDate(request.getEndDate())
                .openingDebt(openingDebt)
                .creditOrders(creditOrderVOs)
                .totalCredit(totalCredit)
                .paymentRecords(periodPaymentVOs)
                .totalPayment(totalPayment)
                .closingDebt(closingDebt)
                .build();
    }

    private Map<Long, BigDecimal> buildPaidAmountMap(List<Long> orderIds) {
        if (orderIds.isEmpty()) {
            return Map.of();
        }
        List<PaymentAllocation> allAllocations = paymentAllocationRepository.findByOrderIdIn(orderIds);
        return allAllocations.stream()
                .collect(Collectors.groupingBy(
                        a -> a.getOrder().getId(),
                        Collectors.reducing(BigDecimal.ZERO, PaymentAllocation::getAllocatedAmount, BigDecimal::add)
                ));
    }

    private CustomerVO toCustomerVO(Customer customer) {
        return CustomerVO.builder()
                .id(customer.getId())
                .name(customer.getName())
                .phone(customer.getPhone())
                .remark(customer.getRemark())
                .totalDebt(customer.getTotalDebt())
                .lastPurchaseAt(customer.getLastPurchaseAt())
                .createdAt(customer.getCreatedAt())
                .build();
    }

    private PaymentRecordVO toPaymentRecordVO(PaymentRecord record) {
        List<PaymentAllocationVO> allocationVOs = record.getAllocations() != null
                ? record.getAllocations().stream().map(this::toPaymentAllocationVO).toList()
                : List.of();

        return PaymentRecordVO.builder()
                .id(record.getId())
                .amount(record.getAmount())
                .remark(record.getRemark())
                .createdAt(record.getCreatedAt())
                .allocations(allocationVOs)
                .build();
    }

    private PaymentAllocationVO toPaymentAllocationVO(PaymentAllocation allocation) {
        return PaymentAllocationVO.builder()
                .orderId(allocation.getOrder().getId())
                .orderNo(allocation.getOrder().getOrderNo())
                .allocatedAmount(allocation.getAllocatedAmount())
                .build();
    }
}
