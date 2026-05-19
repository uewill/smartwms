package com.smartwms.repository;

import com.smartwms.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByPhone(String phone);
    Optional<User> findByWechatOpenId(String wechatOpenId);
    boolean existsByPhone(String phone);
}
