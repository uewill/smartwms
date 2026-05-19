package com.clothing.erp.controller;

import com.clothing.erp.common.Result;
import com.clothing.erp.config.CurrentUser;
import com.clothing.erp.dto.stock.*;
import com.clothing.erp.service.StockService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/shops/{shopId}")
@RequiredArgsConstructor
public class StockController {

    private final StockService stockService;

    @GetMapping("/stock")
    public Result<Page<StockSkuVO>> queryStock(@PathVariable Long shopId,
                                                StockQueryRequest query) {
        Page<StockSkuVO> page = stockService.queryStock(shopId, query);
        return Result.success(page);
    }

    @PutMapping("/stock/warning")
    public Result<Void> setStockWarning(@PathVariable Long shopId,
                                         @Valid @RequestBody SetStockWarningRequest request) {
        stockService.setStockWarning(shopId, request);
        return Result.success();
    }

    @GetMapping("/stock/warnings")
    public Result<List<StockSkuVO>> getWarningStock(@PathVariable Long shopId) {
        List<StockSkuVO> list = stockService.getWarningStock(shopId);
        return Result.success(list);
    }

    @PostMapping("/inventory-checks")
    public Result<InventoryCheckVO> createInventoryCheck(@PathVariable Long shopId,
                                                          @CurrentUser Long userId,
                                                          @Valid @RequestBody CreateInventoryCheckRequest request) {
        InventoryCheckVO vo = stockService.createInventoryCheck(shopId, userId, request);
        return Result.success(vo);
    }

    @GetMapping("/inventory-checks")
    public Result<List<InventoryCheckVO>> listInventoryChecks(@PathVariable Long shopId) {
        List<InventoryCheckVO> list = stockService.listInventoryChecks(shopId);
        return Result.success(list);
    }

    @GetMapping("/inventory-checks/{checkId}")
    public Result<InventoryCheckVO> getInventoryCheck(@PathVariable Long shopId,
                                                       @PathVariable Long checkId) {
        InventoryCheckVO vo = stockService.getInventoryCheck(shopId, checkId);
        return Result.success(vo);
    }

    @PostMapping("/inventory-checks/{checkId}/submit")
    public Result<InventoryCheckVO> submitInventoryCheck(@PathVariable Long shopId,
                                                          @PathVariable Long checkId) {
        InventoryCheckVO vo = stockService.submitInventoryCheck(shopId, checkId);
        return Result.success(vo);
    }

    @PostMapping("/transfers")
    public Result<StockTransferVO> createTransfer(@PathVariable Long shopId,
                                                    @CurrentUser Long userId,
                                                    @Valid @RequestBody CreateTransferRequest request) {
        StockTransferVO vo = stockService.createTransfer(shopId, userId, request);
        return Result.success(vo);
    }

    @GetMapping("/transfers")
    public Result<List<StockTransferVO>> listTransfers(@PathVariable Long shopId) {
        List<StockTransferVO> list = stockService.listTransfers(shopId);
        return Result.success(list);
    }

    @GetMapping("/transfers/{transferId}")
    public Result<StockTransferVO> getTransfer(@PathVariable Long shopId,
                                                 @PathVariable Long transferId) {
        StockTransferVO vo = stockService.getTransfer(shopId, transferId);
        return Result.success(vo);
    }

    @PostMapping("/transfers/{transferId}/confirm")
    public Result<StockTransferVO> confirmTransfer(@PathVariable Long shopId,
                                                     @PathVariable Long transferId) {
        StockTransferVO vo = stockService.confirmTransfer(shopId, transferId);
        return Result.success(vo);
    }
}
