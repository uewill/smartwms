package com.smartwms.middleware;

import com.smartwms.util.JwtUtil;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

@Component
public class AuthInterceptor implements HandlerInterceptor {

    public static final String USER_ID = "userId";
    public static final String TENANT_ID = "tenantId";
    public static final String TOKEN = "token";

    @Autowired
    private JwtUtil jwtUtil;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            return true;
        }

        String token = request.getHeader("Authorization");
        if (token != null && token.startsWith("Bearer ")) {
            token = token.substring(7);
            try {
                Long userId = jwtUtil.getUserIdFromToken(token);
                Long tenantId = jwtUtil.getTenantIdFromToken(token);

                request.setAttribute(USER_ID, userId);
                request.setAttribute(TENANT_ID, tenantId);
                request.setAttribute(TOKEN, token);

                return true;
            } catch (Exception e) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("{\"code\":401,\"message\":\"Token invalid or expired\"}");
                return false;
            }
        }

        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        response.getWriter().write("{\"code\":401,\"message\":\"Authorization header required\"}");
        return false;
    }
}
