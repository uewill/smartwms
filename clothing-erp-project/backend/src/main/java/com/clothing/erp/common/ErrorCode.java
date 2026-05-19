package com.clothing.erp.common;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum ErrorCode {

    SUCCESS(200, "操作成功"),
    BAD_REQUEST(400, "请求参数错误"),
    UNAUTHORIZED(401, "未认证"),
    FORBIDDEN(403, "无权限"),
    NOT_FOUND(404, "资源不存在"),
    METHOD_NOT_ALLOWED(405, "请求方法不允许"),
    CONFLICT(409, "数据冲突"),
    INTERNAL_ERROR(500, "系统内部错误"),

    USER_ALREADY_EXISTS(1001, "用户已存在"),
    USER_NOT_FOUND(1002, "用户不存在"),
    PASSWORD_ERROR(1003, "密码错误"),
    TOKEN_INVALID(1004, "Token无效或已过期"),
    TOKEN_MISSING(1005, "Token缺失"),

    SHOP_NOT_FOUND(3001, "店铺不存在"),
    INVITE_CODE_INVALID(3002, "邀请码无效"),
    INVITE_CODE_EXPIRED(3003, "邀请码已过期"),
    ALREADY_MEMBER(3004, "已是店铺成员"),
    PERMISSION_DENIED(3005, "无操作权限"),
    MEMBER_NOT_FOUND(3006, "成员不存在"),

    PRODUCT_NOT_FOUND(4001, "商品不存在"),
    PRODUCT_STYLE_NO_EXISTS(4002, "款号已存在"),
    SKU_NOT_FOUND(4003, "SKU不存在"),
    SKU_BARCODE_EXISTS(4004, "条码已存在"),

    PARAM_VALIDATION_FAILED(2001, "参数校验失败"),

    CUSTOMER_NOT_FOUND(5001, "客户不存在"),
    CUSTOMER_HAS_DEBT(5002, "客户存在欠款，无法删除"),
    CUSTOMER_NAME_EXISTS(5003, "客户名称已存在"),
    DEBT_AMOUNT_EXCEED(5004, "还款金额超过欠款总额"),
    PREMIUM_REQUIRED(5005, "高级版功能，请升级订阅");

    private final int code;
    private final String message;
}
