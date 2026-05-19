package com.smartwms.repository;

import com.smartwms.entity.Staff;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface StaffRepository extends JpaRepository<Staff, Long> {
    List<Staff> findByTenantId(Long tenantId);
    Optional<Staff> findByUserId(Long userId);
    List<Staff> findByTenantIdAndLevel(Long tenantId, Integer level);
}
