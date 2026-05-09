package com.smartwms.util;

import java.util.Random;

public class SmsCodeUtil {

    private static final String CODE_CHARS = "0123456789";
    private static final int CODE_LENGTH = 6;

    public static String generateCode() {
        Random random = new Random();
        StringBuilder code = new StringBuilder();
        for (int i = 0; i < CODE_LENGTH; i++) {
            code.append(CODE_CHARS.charAt(random.nextInt(CODE_CHARS.length())));
        }
        return code.toString();
    }

    public static boolean validateCode(String inputCode, String realCode) {
        if (inputCode == null || realCode == null) {
            return false;
        }
        return inputCode.equals(realCode);
    }
}
