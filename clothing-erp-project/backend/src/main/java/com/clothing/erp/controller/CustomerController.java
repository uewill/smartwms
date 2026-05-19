package com.clothing.erp.controller;

import com.clothing.erp.common.Result;
import com.clothing.erp.config.CurrentUser;
import com.clothing.erp.dto.customer.*;
import com.clothing.erp.service.CustomerService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/shops/{shopId}/customers")
@RequiredArgsConstructor
public class CustomerController {

    private final CustomerService customerService;

    @PostMapping
    public Result<CustomerVO> createCustomer(@PathVariable Long shopId,
                                              @Valid @RequestBody CreateCustomerRequest request) {
        CustomerVO vo = customerService.createCustomer(shopId, request);
        return Result.success(vo);
    }

    @PutMapping("/{customerId}")
    public Result<CustomerVO> updateCustomer(@PathVariable Long shopId,
                                              @PathVariable Long customerId,
                                              @Valid @RequestBody CreateCustomerRequest request) {
        CustomerVO vo = customerService.updateCustomer(shopId, customerId, request);
        return Result.success(vo);
    }

    @GetMapping("/{customerId}")
    public Result<CustomerVO> getCustomer(@PathVariable Long shopId,
                                           @PathVariable Long customerId) {
        CustomerVO vo = customerService.getCustomer(shopId, customerId);
        return Result.success(vo);
    }

    @GetMapping
    public Result<Page<CustomerVO>> listCustomers(@PathVariable Long shopId,
                                                   CustomerQueryRequest query) {
        Page<CustomerVO> page = customerService.listCustomers(shopId, query);
        return Result.success(page);
    }

    @DeleteMapping("/{customerId}")
    public Result<Void> deleteCustomer(@PathVariable Long shopId,
                                        @PathVariable Long customerId) {
        customerService.deleteCustomer(shopId, customerId);
        return Result.success();
    }

    @PostMapping("/collect-debt")
    public Result<PaymentRecordVO> collectDebt(@PathVariable Long shopId,
                                                @CurrentUser Long userId,
                                                @Valid @RequestBody CollectDebtRequest request) {
        PaymentRecordVO vo = customerService.collectDebt(shopId, userId, request);
        return Result.success(vo);
    }

    @GetMapping("/{customerId}/debt-detail")
    public Result<CustomerDebtDetailVO> getDebtDetail(@PathVariable Long shopId,
                                                       @PathVariable Long customerId) {
        CustomerDebtDetailVO vo = customerService.getDebtDetail(shopId, customerId);
        return Result.success(vo);
    }

    @PostMapping("/statement")
    public Result<StatementVO> generateStatement(@PathVariable Long shopId,
                                                  @Valid @RequestBody StatementRequest request) {
        StatementVO vo = customerService.generateStatement(shopId, request);
        return Result.success(vo);
    }
}
