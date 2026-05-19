package com.smartwms.service;

import com.smartwms.entity.Product;
import com.smartwms.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class ProductService {

    @Autowired
    private ProductRepository productRepository;

    public List<Product> getProducts(Long tenantId, String keyword, String category) {
        if (keyword != null && !keyword.isEmpty()) {
            return productRepository.searchByKeyword(tenantId, keyword);
        }
        return productRepository.findByTenantId(tenantId);
    }

    public Product getProduct(Long id) {
        return productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("商品不存在"));
    }

    @Transactional
    public Product createProduct(Long tenantId, Product product) {
        if (productRepository.existsByCode(product.getCode())) {
            throw new RuntimeException("商品编码已存在");
        }

        product.setTenantId(tenantId);
        product.setStockQuantity(0);
        return productRepository.save(product);
    }

    @Transactional
    public Product updateProduct(Long id, Product product) {
        Product existing = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("商品不存在"));

        existing.setName(product.getName());
        existing.setSpec(product.getSpec());
        existing.setUnit(product.getUnit());
        existing.setPrice(product.getPrice());
        existing.setCostPrice(product.getCostPrice());
        existing.setWarningStock(product.getWarningStock());
        existing.setCategory(product.getCategory());
        existing.setRemark(product.getRemark());
        existing.setImage(product.getImage());

        return productRepository.save(existing);
    }

    @Transactional
    public void deleteProduct(Long id) {
        productRepository.deleteById(id);
    }

    public List<Product> getLowStockProducts(Long tenantId) {
        return productRepository.findLowStockByTenantId(tenantId);
    }
}
