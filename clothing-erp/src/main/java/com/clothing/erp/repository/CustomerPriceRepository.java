package com.clothing.erp.repository;

import com.clothing.erp.entity.CustomerPrice;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface CustomerPriceRepository extends JpaRepository<CustomerPrice, Long> {

    Optional<CustomerPrice> findByCustomerIdAndSkuId(Long customerId, Long skuId);

    List<CustomerPrice> findByCustomerId(Long customerId);

    void deleteByCustomerId(Long customerId);
}
