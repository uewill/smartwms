package com.clothing.erp.repository;

import com.clothing.erp.entity.SysUser;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface SysUserRepository extends JpaRepository<SysUser, Long> {

    Optional<SysUser> findByPhone(String phone);
}
