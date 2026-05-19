package com.clothing.erp.controller;

import com.clothing.erp.common.Result;
import com.clothing.erp.dto.report.*;
import com.clothing.erp.service.ReportService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

@RestController
@RequestMapping("/api/shops/{shopId}/reports")
@RequiredArgsConstructor
public class ReportController {

    private final ReportService reportService;

    @GetMapping("/today-summary")
    public Result<TodaySummaryVO> getTodaySummary(@PathVariable Long shopId) {
        TodaySummaryVO vo = reportService.getTodaySummary(shopId);
        return Result.success(vo);
    }

    @GetMapping("/hot-products")
    public Result<List<HotProductVO>> getHotProducts(@PathVariable Long shopId,
                                                      HotProductQueryRequest request) {
        List<HotProductVO> list = reportService.getHotProducts(shopId, request);
        return Result.success(list);
    }

    @GetMapping("/overstock")
    public Result<List<OverstockVO>> getOverstock(@PathVariable Long shopId) {
        List<OverstockVO> list = reportService.getOverstock(shopId);
        return Result.success(list);
    }

    @GetMapping("/customer-debt")
    public Result<List<CustomerDebtSummaryVO>> getCustomerDebtSummary(@PathVariable Long shopId) {
        List<CustomerDebtSummaryVO> list = reportService.getCustomerDebtSummary(shopId);
        return Result.success(list);
    }

    @GetMapping("/profit-analysis")
    public Result<ProfitAnalysisVO> getProfitAnalysis(@PathVariable Long shopId,
                                                       ReportQueryRequest request) {
        ProfitAnalysisVO vo = reportService.getProfitAnalysis(shopId, request);
        return Result.success(vo);
    }

    @GetMapping("/export/hot-products")
    public ResponseEntity<byte[]> exportHotProducts(@PathVariable Long shopId,
                                                     HotProductQueryRequest request) throws Exception {
        byte[] data = reportService.exportHotProducts(shopId, request);
        String fileName = URLEncoder.encode("热卖排行.xlsx", StandardCharsets.UTF_8);
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename*=UTF-8''" + fileName)
                .contentType(MediaType.parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"))
                .body(data);
    }

    @GetMapping("/export/customer-debt")
    public ResponseEntity<byte[]> exportCustomerDebt(@PathVariable Long shopId) throws Exception {
        byte[] data = reportService.exportCustomerDebt(shopId);
        String fileName = URLEncoder.encode("客户欠款.xlsx", StandardCharsets.UTF_8);
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename*=UTF-8''" + fileName)
                .contentType(MediaType.parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"))
                .body(data);
    }

    @GetMapping("/export/profit-analysis")
    public ResponseEntity<byte[]> exportProfitAnalysis(@PathVariable Long shopId,
                                                        ReportQueryRequest request) throws Exception {
        byte[] data = reportService.exportProfitAnalysis(shopId, request);
        String fileName = URLEncoder.encode("利润分析.xlsx", StandardCharsets.UTF_8);
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename*=UTF-8''" + fileName)
                .contentType(MediaType.parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"))
                .body(data);
    }
}
