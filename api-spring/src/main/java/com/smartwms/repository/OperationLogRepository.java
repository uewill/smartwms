package com.smartwms.repository;

import com.smartwms.entity.OperationLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface OperationLogRepository extends JpaRepository<OperationLog, Long> {
    List<OperationLog> findByTenantIdOrderByCreatedAtDesc(Long tenantId);
    List<OperationLog> findByStaffIdOrderByCreatedAtDesc(Long staffId);
}
