package com.smartwms.repository;

import com.smartwms.entity.SmsCode;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface SmsCodeRepository extends JpaRepository<SmsCode, Long> {
    Optional<SmsCode> findTopByPhoneAndTypeOrderByCreatedAtDesc(String phone, String type);

    @Modifying
    @Query("DELETE FROM SmsCode s WHERE s.phone = ?1 AND s.type = ?2")
    void deleteByPhoneAndType(String phone, String type);
}
