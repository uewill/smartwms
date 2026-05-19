package com.smartwms.service;

import com.smartwms.dto.AuthResult;
import com.smartwms.dto.LoginRequest;
import com.smartwms.dto.RegisterRequest;
import com.smartwms.entity.*;
import com.smartwms.repository.*;
import com.smartwms.util.JwtUtil;
import com.smartwms.util.PasswordUtil;
import com.smartwms.util.SmsCodeUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class AuthService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private StaffRepository staffRepository;

    @Autowired
    private TenantRepository tenantRepository;

    @Autowired
    private SmsCodeRepository smsCodeRepository;

    @Autowired
    private OperationLogRepository operationLogRepository;

    @Autowired
    private JwtUtil jwtUtil;

    @Transactional
    public AuthResult sendCode(String phone, String type) {
        String code = SmsCodeUtil.generateCode();

        smsCodeRepository.deleteByPhoneAndType(phone, type);

        SmsCode smsCode = new SmsCode();
        smsCode.setPhone(phone);
        smsCode.setCode(code);
        smsCode.setType(type);
        smsCode.setExpireTime(LocalDateTime.now().plusMinutes(5));
        smsCode.setCreatedAt(LocalDateTime.now());
        smsCodeRepository.save(smsCode);

        System.out.println("SMS Code for " + phone + ": " + code);

        return null;
    }

    @Transactional
    public AuthResult loginByCode(String phone, String code) {
        SmsCode smsCode = smsCodeRepository.findTopByPhoneAndTypeOrderByCreatedAtDesc(phone, "login")
                .orElseThrow(() -> new RuntimeException("验证码不存在"));

        if (smsCode.isExpired()) {
            throw new RuntimeException("验证码已过期");
        }

        if (!SmsCodeUtil.validateCode(code, smsCode.getCode())) {
            throw new RuntimeException("验证码错误");
        }

        User user = userRepository.findByPhone(phone)
                .orElseThrow(() -> new RuntimeException("用户不存在"));

        user.setLastLoginAt(LocalDateTime.now());
        userRepository.save(user);

        return buildAuthResult(user);
    }

    @Transactional
    public AuthResult loginByPassword(String phone, String password) {
        User user = userRepository.findByPhone(phone)
                .orElseThrow(() -> new RuntimeException("用户不存在或密码错误"));

        if (user.getPassword() == null || !PasswordUtil.matches(password, user.getPassword())) {
            throw new RuntimeException("用户不存在或密码错误");
        }

        user.setLastLoginAt(LocalDateTime.now());
        userRepository.save(user);

        return buildAuthResult(user);
    }

    @Transactional
    public AuthResult register(RegisterRequest request) {
        if (userRepository.existsByPhone(request.getPhone())) {
            throw new RuntimeException("手机号已注册");
        }

        Tenant tenant = new Tenant();
        tenant.setName(request.getName() + "的仓库");
        tenant.setPhone(request.getPhone());
        tenant.setStatus(1);
        tenantRepository.save(tenant);

        User user = new User();
        user.setTenantId(tenant.getId());
        user.setPhone(request.getPhone());
        user.setNickname(request.getName());
        if (request.getPassword() != null && !request.getPassword().isEmpty()) {
            user.setPassword(PasswordUtil.encode(request.getPassword()));
        }
        user.setStatus(1);
        userRepository.save(user);

        Staff staff = new Staff();
        staff.setTenantId(tenant.getId());
        staff.setUserId(user.getId());
        staff.setName(request.getName());
        staff.setPhone(request.getPhone());
        staff.setLevel(1);
        staff.setPermissions("*");
        staff.setStatus("active");
        staffRepository.save(staff);

        return buildAuthResult(user);
    }

    @Transactional
    public AuthResult wxLogin(String wxOpenid) {
        User user = userRepository.findByWechatOpenId(wxOpenid)
                .orElseThrow(() -> new RuntimeException("微信未绑定账号"));

        user.setLastLoginAt(LocalDateTime.now());
        userRepository.save(user);

        return buildAuthResult(user);
    }

    @Transactional
    public AuthResult getUserInfo(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
        return buildAuthResult(user);
    }

    @Transactional
    public void bindWechat(Long userId, String wxOpenid) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("用户不存在"));

        user.setWechatOpenId(wxOpenid);
        userRepository.save(user);
    }

    @Transactional
    public void changePassword(Long userId, String oldPassword, String newPassword) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("用户不存在"));

        if (user.getPassword() != null && !PasswordUtil.matches(oldPassword, user.getPassword())) {
            throw new RuntimeException("原密码错误");
        }

        user.setPassword(PasswordUtil.encode(newPassword));
        userRepository.save(user);
    }

    public List<OperationLog> getOperationLogs(Long tenantId) {
        return operationLogRepository.findByTenantIdOrderByCreatedAtDesc(tenantId);
    }

    private AuthResult buildAuthResult(User user) {
        String token = jwtUtil.generateToken(user.getId(), user.getTenantId());

        Tenant tenant = tenantRepository.findById(user.getTenantId()).orElse(null);
        Staff staff = staffRepository.findByUserId(user.getId()).orElse(null);

        AuthResult.UserDto userDto = AuthResult.UserDto.fromEntity(user);
        AuthResult.TenantDto tenantDto = AuthResult.TenantDto.fromEntity(tenant);
        AuthResult.StaffDto staffDto = AuthResult.StaffDto.fromEntity(staff);

        return new AuthResult(token, userDto, staffDto, tenantDto);
    }

    public AuthResult bindWechatByCode(Long userId, String phone, String code) {
        SmsCode smsCode = smsCodeRepository.findTopByPhoneAndTypeOrderByCreatedAtDesc(phone, "bind")
                .orElseThrow(() -> new RuntimeException("验证码不存在"));

        if (smsCode.isExpired()) {
            throw new RuntimeException("验证码已过期");
        }

        if (!SmsCodeUtil.validateCode(code, smsCode.getCode())) {
            throw new RuntimeException("验证码错误");
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("用户不存在"));

        user.setWechatOpenId("wx_" + phone);
        userRepository.save(user);

        return buildAuthResult(user);
    }
}
