package com.smartwms.service;

import com.smartwms.dto.AuthResult;
import com.smartwms.dto.RegisterRequest;
import com.smartwms.entity.SmsCode;
import com.smartwms.entity.Staff;
import com.smartwms.entity.Tenant;
import com.smartwms.entity.User;
import com.smartwms.repository.SmsCodeRepository;
import com.smartwms.repository.StaffRepository;
import com.smartwms.repository.TenantRepository;
import com.smartwms.repository.UserRepository;
import com.smartwms.util.JwtUtil;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private StaffRepository staffRepository;

    @Mock
    private TenantRepository tenantRepository;

    @Mock
    private SmsCodeRepository smsCodeRepository;

    @Mock
    private com.smartwms.repository.OperationLogRepository operationLogRepository;

    @Mock
    private JwtUtil jwtUtil;

    @InjectMocks
    private AuthService authService;

    private User testUser;
    private Tenant testTenant;

    @BeforeEach
    void setUp() {
        testTenant = new Tenant();
        testTenant.setId(1L);
        testTenant.setName("测试租户");
        testTenant.setPhone("13800138000");
        testTenant.setStatus(1);

        testUser = new User();
        testUser.setId(1L);
        testUser.setTenantId(1L);
        testUser.setPhone("13800138000");
        testUser.setNickname("测试用户");
        testUser.setStatus(1);
    }

    @Test
    void testLoginByPassword_Success() {
        when(userRepository.findByPhone("13800138000")).thenReturn(Optional.of(testUser));
        when(userRepository.save(any(User.class))).thenReturn(testUser);
        when(jwtUtil.generateToken(1L, 1L)).thenReturn("test-jwt-token");
        when(tenantRepository.findById(1L)).thenReturn(Optional.of(testTenant));
        when(staffRepository.findByUserId(1L)).thenReturn(Optional.empty());

        AuthResult result = authService.loginByPassword("13800138000", "password123");

        assertNotNull(result);
        assertEquals("test-jwt-token", result.getToken());
        verify(userRepository).save(any(User.class));
    }

    @Test
    void testLoginByPassword_UserNotFound() {
        when(userRepository.findByPhone("13800138000")).thenReturn(Optional.empty());

        assertThrows(RuntimeException.class, () -> {
            authService.loginByPassword("13800138000", "password123");
        });
    }

    @Test
    void testLoginByCode_Success() {
        SmsCode smsCode = new SmsCode();
        smsCode.setPhone("13800138000");
        smsCode.setCode("123456");
        smsCode.setType("login");
        smsCode.setExpireTime(LocalDateTime.now().plusMinutes(5));

        when(smsCodeRepository.findTopByPhoneAndTypeOrderByCreatedAtDesc("13800138000", "login"))
                .thenReturn(Optional.of(smsCode));
        when(userRepository.findByPhone("13800138000")).thenReturn(Optional.of(testUser));
        when(userRepository.save(any(User.class))).thenReturn(testUser);
        when(jwtUtil.generateToken(1L, 1L)).thenReturn("test-jwt-token");
        when(tenantRepository.findById(1L)).thenReturn(Optional.of(testTenant));
        when(staffRepository.findByUserId(1L)).thenReturn(Optional.empty());

        AuthResult result = authService.loginByCode("13800138000", "123456");

        assertNotNull(result);
        assertEquals("test-jwt-token", result.getToken());
    }

    @Test
    void testLoginByCode_CodeExpired() {
        SmsCode smsCode = new SmsCode();
        smsCode.setPhone("13800138000");
        smsCode.setCode("123456");
        smsCode.setType("login");
        smsCode.setExpireTime(LocalDateTime.now().minusMinutes(1));

        when(smsCodeRepository.findTopByPhoneAndTypeOrderByCreatedAtDesc("13800138000", "login"))
                .thenReturn(Optional.of(smsCode));

        assertThrows(RuntimeException.class, () -> {
            authService.loginByCode("13800138000", "123456");
        });
    }

    @Test
    void testLoginByCode_InvalidCode() {
        SmsCode smsCode = new SmsCode();
        smsCode.setPhone("13800138000");
        smsCode.setCode("123456");
        smsCode.setType("login");
        smsCode.setExpireTime(LocalDateTime.now().plusMinutes(5));

        when(smsCodeRepository.findTopByPhoneAndTypeOrderByCreatedAtDesc("13800138000", "login"))
                .thenReturn(Optional.of(smsCode));

        assertThrows(RuntimeException.class, () -> {
            authService.loginByCode("13800138000", "wrongcode");
        });
    }

    @Test
    void testRegister_Success() {
        RegisterRequest request = new RegisterRequest();
        request.setPhone("13800138001");
        request.setName("新用户");
        request.setPassword("password123");

        Tenant savedTenant = new Tenant();
        savedTenant.setId(2L);

        User savedUser = new User();
        savedUser.setId(2L);
        savedUser.setTenantId(2L);
        savedUser.setPhone("13800138001");

        when(userRepository.existsByPhone("13800138001")).thenReturn(false);
        when(tenantRepository.save(any(Tenant.class))).thenReturn(savedTenant);
        when(userRepository.save(any(User.class))).thenReturn(savedUser);
        when(staffRepository.save(any(Staff.class))).thenReturn(new Staff());
        when(jwtUtil.generateToken(2L, 2L)).thenReturn("test-jwt-token");
        when(tenantRepository.findById(2L)).thenReturn(Optional.of(savedTenant));
        when(staffRepository.findByUserId(2L)).thenReturn(Optional.empty());

        AuthResult result = authService.register(request);

        assertNotNull(result);
        assertEquals("test-jwt-token", result.getToken());
        verify(tenantRepository).save(any(Tenant.class));
        verify(userRepository).save(any(User.class));
        verify(staffRepository).save(any(Staff.class));
    }

    @Test
    void testRegister_PhoneAlreadyExists() {
        RegisterRequest request = new RegisterRequest();
        request.setPhone("13800138000");
        request.setName("测试用户");

        when(userRepository.existsByPhone("13800138000")).thenReturn(true);

        assertThrows(RuntimeException.class, () -> {
            authService.register(request);
        });
    }

    @Test
    void testGetUserInfo_Success() {
        when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));
        when(jwtUtil.generateToken(1L, 1L)).thenReturn("test-jwt-token");
        when(tenantRepository.findById(1L)).thenReturn(Optional.of(testTenant));
        when(staffRepository.findByUserId(1L)).thenReturn(Optional.empty());

        AuthResult result = authService.getUserInfo(1L);

        assertNotNull(result);
        assertEquals("test-jwt-token", result.getToken());
    }

    @Test
    void testGetUserInfo_UserNotFound() {
        when(userRepository.findById(999L)).thenReturn(Optional.empty());

        assertThrows(RuntimeException.class, () -> {
            authService.getUserInfo(999L);
        });
    }

    @Test
    void testBindWechat_Success() {
        when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));
        when(userRepository.save(any(User.class))).thenReturn(testUser);
        when(jwtUtil.generateToken(1L, 1L)).thenReturn("test-jwt-token");
        when(tenantRepository.findById(1L)).thenReturn(Optional.of(testTenant));
        when(staffRepository.findByUserId(1L)).thenReturn(Optional.empty());

        authService.bindWechat(1L, "wx_openid_123");

        verify(userRepository).save(any(User.class));
        assertEquals("wx_openid_123", testUser.getWechatOpenId());
    }

    @Test
    void testChangePassword_Success() {
        String encodedPassword = "$2a$10$encodedPassword";
        testUser.setPassword(encodedPassword);

        when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));
        when(userRepository.save(any(User.class))).thenReturn(testUser);

        authService.changePassword(1L, "oldpassword", "newpassword");

        verify(userRepository).save(any(User.class));
    }
}
