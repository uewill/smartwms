package com.clothing.erp.service;

import com.clothing.erp.common.ErrorCode;
import com.clothing.erp.dto.stock.*;
import com.clothing.erp.entity.*;
import com.clothing.erp.exception.BusinessException;
import com.clothing.erp.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class StockService {

    private final ProductSkuRepository productSkuRepository;
    private final ShopRepository shopRepository;
    private final StockMovementRepository stockMovementRepository;
    private final InventoryCheckRepository inventoryCheckRepository;
    private final StockTransferRepository stockTransferRepository;

    @Transactional(readOnly = true)
    public Page<StockSkuVO> queryStock(Long shopId, StockQueryRequest query) {
        Pageable pageable = PageRequest.of(query.getPage(), query.getSize());

        Product.Season season = null;
        if (query.getSeason() != null && !query.getSeason().isEmpty()) {
            season = Product.Season.valueOf(query.getSeason());
        }

        Boolean warningOnly = query.getWarningOnly();

        Page<ProductSku> page = productSkuRepository.findByShopIdWithStockFilter(
                shopId, query.getKeyword(), season, query.getBrand(), warningOnly, pageable);

        return page.map(this::toStockSkuVO);
    }

    @Transactional
    public void setStockWarning(Long shopId, SetStockWarningRequest request) {
        ProductSku sku = productSkuRepository.findById(request.getSkuId())
                .orElseThrow(() -> new BusinessException(ErrorCode.SKU_NOT_FOUND, "SKU不存在"));
        if (!sku.getProduct().getShop().getId().equals(shopId)) {
            throw new BusinessException(ErrorCode.PERMISSION_DENIED, "SKU不属于当前店铺");
        }
        sku.setStockWarningQty(request.getStockWarningQty());
        productSkuRepository.save(sku);
    }

    @Transactional(readOnly = true)
    public List<StockSkuVO> getWarningStock(Long shopId) {
        List<ProductSku> skus = productSkuRepository.findWarningByShopId(shopId);
        return skus.stream().map(this::toStockSkuVO).toList();
    }

    @Transactional
    public InventoryCheckVO createInventoryCheck(Long shopId, Long userId, CreateInventoryCheckRequest request) {
        Shop shop = shopRepository.findById(shopId)
                .orElseThrow(() -> new BusinessException(ErrorCode.SHOP_NOT_FOUND));

        if (request.getItems() == null || request.getItems().isEmpty()) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "盘点明细不能为空");
        }

        InventoryCheck.ScopeType scopeType = InventoryCheck.ScopeType.valueOf(request.getScopeType());

        List<Long> skuIds = request.getItems().stream()
                .map(InventoryCheckItemDTO::getSkuId)
                .distinct()
                .toList();
        List<ProductSku> skus = productSkuRepository.findAllById(skuIds);
        Map<Long, ProductSku> skuMap = skus.stream()
                .collect(Collectors.toMap(ProductSku::getId, Function.identity()));

        for (InventoryCheckItemDTO item : request.getItems()) {
            ProductSku sku = skuMap.get(item.getSkuId());
            if (sku == null) {
                throw new BusinessException(ErrorCode.SKU_NOT_FOUND, "SKU不存在: " + item.getSkuId());
            }
            if (!sku.getProduct().getShop().getId().equals(shopId)) {
                throw new BusinessException(ErrorCode.PERMISSION_DENIED, "SKU不属于当前店铺: " + item.getSkuId());
            }
        }

        String checkNo = generateCheckNo(shopId);

        InventoryCheck check = new InventoryCheck();
        check.setShop(shop);
        check.setCheckNo(checkNo);
        check.setScopeType(scopeType);
        check.setScopeValue(request.getScopeValue());
        check.setStatus(InventoryCheck.InventoryCheckStatus.DRAFT);

        List<InventoryCheckItem> checkItems = new ArrayList<>();
        for (InventoryCheckItemDTO itemDTO : request.getItems()) {
            ProductSku sku = skuMap.get(itemDTO.getSkuId());
            int diffQty = itemDTO.getActualQty() - sku.getStockQty();

            InventoryCheckItem checkItem = new InventoryCheckItem();
            checkItem.setCheck(check);
            checkItem.setSku(sku);
            checkItem.setSystemQty(sku.getStockQty());
            checkItem.setActualQty(itemDTO.getActualQty());
            checkItem.setDiffQty(diffQty);
            checkItems.add(checkItem);
        }

        check.setItems(checkItems);
        InventoryCheck savedCheck = inventoryCheckRepository.save(check);

        return toInventoryCheckVO(savedCheck);
    }

    @Transactional(readOnly = true)
    public InventoryCheckVO getInventoryCheck(Long shopId, Long checkId) {
        InventoryCheck check = inventoryCheckRepository.findByIdAndShopId(checkId, shopId)
                .orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "盘点单不存在"));
        return toInventoryCheckVO(check);
    }

    @Transactional(readOnly = true)
    public List<InventoryCheckVO> listInventoryChecks(Long shopId) {
        List<InventoryCheck> checks = inventoryCheckRepository.findByShopId(shopId);
        return checks.stream().map(this::toInventoryCheckVO).toList();
    }

    @Transactional
    public InventoryCheckVO submitInventoryCheck(Long shopId, Long checkId) {
        InventoryCheck check = inventoryCheckRepository.findByIdAndShopId(checkId, shopId)
                .orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "盘点单不存在"));

        if (check.getStatus() == InventoryCheck.InventoryCheckStatus.COMPLETED) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "盘点单已提交，不能重复提交");
        }

        Shop shop = check.getShop();

        for (InventoryCheckItem item : check.getItems()) {
            ProductSku sku = item.getSku();
            int diffQty = item.getDiffQty();

            if (diffQty != 0) {
                sku.setStockQty(item.getActualQty());
                productSkuRepository.save(sku);

                StockMovement movement = new StockMovement();
                movement.setShop(shop);
                movement.setSku(sku);
                movement.setMovementType(diffQty > 0 ? StockMovement.MovementType.IN : StockMovement.MovementType.OUT);
                movement.setQuantity(Math.abs(diffQty));
                movement.setRefType(StockMovement.RefType.INVENTORY);
                movement.setRefId(check.getId());
                movement.setRemark(diffQty > 0
                        ? "盘盈入库 " + check.getCheckNo()
                        : "盘亏出库 " + check.getCheckNo());
                stockMovementRepository.save(movement);
            }
        }

        check.setStatus(InventoryCheck.InventoryCheckStatus.COMPLETED);
        inventoryCheckRepository.save(check);

        return toInventoryCheckVO(check);
    }

    @Transactional
    public StockTransferVO createTransfer(Long shopId, Long userId, CreateTransferRequest request) {
        Shop shopFrom = shopRepository.findById(shopId)
                .orElseThrow(() -> new BusinessException(ErrorCode.SHOP_NOT_FOUND));
        Shop shopTo = shopRepository.findById(request.getShopIdTo())
                .orElseThrow(() -> new BusinessException(ErrorCode.SHOP_NOT_FOUND, "目标店铺不存在"));

        if (shopId.equals(request.getShopIdTo())) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "调出方和调入方不能是同一店铺");
        }

        if (request.getItems() == null || request.getItems().isEmpty()) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "调拨商品列表不能为空");
        }

        List<Long> skuIds = request.getItems().stream()
                .map(TransferItemDTO::getSkuId)
                .distinct()
                .toList();
        List<ProductSku> skus = productSkuRepository.findAllById(skuIds);
        Map<Long, ProductSku> skuMap = skus.stream()
                .collect(Collectors.toMap(ProductSku::getId, Function.identity()));

        for (TransferItemDTO item : request.getItems()) {
            ProductSku sku = skuMap.get(item.getSkuId());
            if (sku == null) {
                throw new BusinessException(ErrorCode.SKU_NOT_FOUND, "SKU不存在: " + item.getSkuId());
            }
            if (!sku.getProduct().getShop().getId().equals(shopId)) {
                throw new BusinessException(ErrorCode.PERMISSION_DENIED, "SKU不属于当前店铺: " + item.getSkuId());
            }
            if (sku.getStockQty() < item.getQuantity()) {
                throw new BusinessException(ErrorCode.BAD_REQUEST,
                        "库存不足: " + sku.getProduct().getStyleNo() + " 库存" + sku.getStockQty());
            }
        }

        String transferNo = generateTransferNo(shopId);

        StockTransfer transfer = new StockTransfer();
        transfer.setShopFrom(shopFrom);
        transfer.setShopTo(shopTo);
        transfer.setTransferNo(transferNo);
        transfer.setStatus(StockTransfer.TransferStatus.PENDING);

        List<StockTransferItem> transferItems = new ArrayList<>();
        for (TransferItemDTO itemDTO : request.getItems()) {
            ProductSku sku = skuMap.get(itemDTO.getSkuId());

            StockTransferItem transferItem = new StockTransferItem();
            transferItem.setTransfer(transfer);
            transferItem.setSku(sku);
            transferItem.setQuantity(itemDTO.getQuantity());
            transferItems.add(transferItem);
        }

        transfer.setItems(transferItems);
        StockTransfer savedTransfer = stockTransferRepository.save(transfer);

        for (TransferItemDTO itemDTO : request.getItems()) {
            ProductSku sku = skuMap.get(itemDTO.getSkuId());
            sku.setStockQty(sku.getStockQty() - itemDTO.getQuantity());
            productSkuRepository.save(sku);

            StockMovement movement = new StockMovement();
            movement.setShop(shopFrom);
            movement.setSku(sku);
            movement.setMovementType(StockMovement.MovementType.OUT);
            movement.setQuantity(itemDTO.getQuantity());
            movement.setRefType(StockMovement.RefType.TRANSFER);
            movement.setRefId(savedTransfer.getId());
            movement.setRemark("调拨出库 " + savedTransfer.getTransferNo());
            stockMovementRepository.save(movement);
        }

        return toStockTransferVO(savedTransfer);
    }

    @Transactional(readOnly = true)
    public StockTransferVO getTransfer(Long shopId, Long transferId) {
        StockTransfer transfer = stockTransferRepository.findById(transferId)
                .orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "调拨单不存在"));
        if (!transfer.getShopFrom().getId().equals(shopId) && !transfer.getShopTo().getId().equals(shopId)) {
            throw new BusinessException(ErrorCode.PERMISSION_DENIED, "无操作权限");
        }
        return toStockTransferVO(transfer);
    }

    @Transactional(readOnly = true)
    public List<StockTransferVO> listTransfers(Long shopId) {
        List<StockTransfer> transfers = stockTransferRepository.findByShopIdFromOrShopIdTo(shopId);
        return transfers.stream().map(this::toStockTransferVO).toList();
    }

    @Transactional
    public StockTransferVO confirmTransfer(Long shopId, Long transferId) {
        StockTransfer transfer = stockTransferRepository.findById(transferId)
                .orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "调拨单不存在"));

        if (!transfer.getShopTo().getId().equals(shopId)) {
            throw new BusinessException(ErrorCode.PERMISSION_DENIED, "只有调入方可以确认调拨");
        }

        if (transfer.getStatus() == StockTransfer.TransferStatus.CONFIRMED) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "调拨单已确认，不能重复确认");
        }

        Shop shopTo = transfer.getShopTo();

        for (StockTransferItem item : transfer.getItems()) {
            ProductSku sku = item.getSku();
            sku.setStockQty(sku.getStockQty() + item.getQuantity());
            productSkuRepository.save(sku);

            StockMovement movement = new StockMovement();
            movement.setShop(shopTo);
            movement.setSku(sku);
            movement.setMovementType(StockMovement.MovementType.IN);
            movement.setQuantity(item.getQuantity());
            movement.setRefType(StockMovement.RefType.TRANSFER);
            movement.setRefId(transfer.getId());
            movement.setRemark("调拨入库 " + transfer.getTransferNo());
            stockMovementRepository.save(movement);
        }

        transfer.setStatus(StockTransfer.TransferStatus.CONFIRMED);
        stockTransferRepository.save(transfer);

        return toStockTransferVO(transfer);
    }

    private String generateCheckNo(Long shopId) {
        String dateStr = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        String prefixWithDate = "IC" + dateStr;
        String maxCheckNo = inventoryCheckRepository.findMaxCheckNoByShopIdAndPrefix(shopId, prefixWithDate + "%");

        int seq = 1;
        if (maxCheckNo != null && maxCheckNo.length() > prefixWithDate.length()) {
            String seqStr = maxCheckNo.substring(prefixWithDate.length());
            try {
                seq = Integer.parseInt(seqStr) + 1;
            } catch (NumberFormatException e) {
                seq = 1;
            }
        }

        return prefixWithDate + String.format("%04d", seq);
    }

    private String generateTransferNo(Long shopId) {
        String dateStr = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        String prefixWithDate = "TR" + dateStr;
        String maxTransferNo = stockTransferRepository.findMaxTransferNoByShopIdAndPrefix(shopId, prefixWithDate + "%");

        int seq = 1;
        if (maxTransferNo != null && maxTransferNo.length() > prefixWithDate.length()) {
            String seqStr = maxTransferNo.substring(prefixWithDate.length());
            try {
                seq = Integer.parseInt(seqStr) + 1;
            } catch (NumberFormatException e) {
                seq = 1;
            }
        }

        return prefixWithDate + String.format("%04d", seq);
    }

    private StockSkuVO toStockSkuVO(ProductSku sku) {
        boolean isWarning = sku.getStockWarningQty() > 0 && sku.getStockQty() <= sku.getStockWarningQty();
        return StockSkuVO.builder()
                .skuId(sku.getId())
                .styleNo(sku.getProduct().getStyleNo())
                .productName(sku.getProduct().getName())
                .colorName(sku.getColor() != null ? sku.getColor().getColorName() : null)
                .sizeName(sku.getSize() != null ? sku.getSize().getSizeName() : null)
                .stockQty(sku.getStockQty())
                .stockWarningQty(sku.getStockWarningQty())
                .isWarning(isWarning)
                .build();
    }

    private InventoryCheckVO toInventoryCheckVO(InventoryCheck check) {
        List<InventoryCheckItemVO> itemVOs = check.getItems() != null
                ? check.getItems().stream().map(this::toInventoryCheckItemVO).toList()
                : List.of();

        return InventoryCheckVO.builder()
                .id(check.getId())
                .checkNo(check.getCheckNo())
                .scopeType(check.getScopeType() != null ? check.getScopeType().name() : null)
                .scopeValue(check.getScopeValue())
                .status(check.getStatus() != null ? check.getStatus().name() : null)
                .items(itemVOs)
                .createdAt(check.getCreatedAt())
                .build();
    }

    private InventoryCheckItemVO toInventoryCheckItemVO(InventoryCheckItem item) {
        return InventoryCheckItemVO.builder()
                .id(item.getId())
                .skuId(item.getSku() != null ? item.getSku().getId() : null)
                .styleNo(item.getSku() != null && item.getSku().getProduct() != null
                        ? item.getSku().getProduct().getStyleNo() : null)
                .colorName(item.getSku() != null && item.getSku().getColor() != null
                        ? item.getSku().getColor().getColorName() : null)
                .sizeName(item.getSku() != null && item.getSku().getSize() != null
                        ? item.getSku().getSize().getSizeName() : null)
                .systemQty(item.getSystemQty())
                .actualQty(item.getActualQty())
                .diffQty(item.getDiffQty())
                .build();
    }

    private StockTransferVO toStockTransferVO(StockTransfer transfer) {
        List<StockTransferItemVO> itemVOs = transfer.getItems() != null
                ? transfer.getItems().stream().map(this::toStockTransferItemVO).toList()
                : List.of();

        return StockTransferVO.builder()
                .id(transfer.getId())
                .transferNo(transfer.getTransferNo())
                .shopIdFrom(transfer.getShopFrom().getId())
                .shopNameFrom(transfer.getShopFrom().getName())
                .shopIdTo(transfer.getShopTo().getId())
                .shopNameTo(transfer.getShopTo().getName())
                .status(transfer.getStatus() != null ? transfer.getStatus().name() : null)
                .items(itemVOs)
                .createdAt(transfer.getCreatedAt())
                .build();
    }

    private StockTransferItemVO toStockTransferItemVO(StockTransferItem item) {
        return StockTransferItemVO.builder()
                .id(item.getId())
                .skuId(item.getSku() != null ? item.getSku().getId() : null)
                .styleNo(item.getSku() != null && item.getSku().getProduct() != null
                        ? item.getSku().getProduct().getStyleNo() : null)
                .colorName(item.getSku() != null && item.getSku().getColor() != null
                        ? item.getSku().getColor().getColorName() : null)
                .sizeName(item.getSku() != null && item.getSku().getSize() != null
                        ? item.getSku().getSize().getSizeName() : null)
                .quantity(item.getQuantity())
                .build();
    }
}
