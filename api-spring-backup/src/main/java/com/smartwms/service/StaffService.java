package com.smartwms.service;

import com.smartwms.entity.Staff;
import com.smartwms.repository.StaffRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class StaffService {

    @Autowired
    private StaffRepository staffRepository;

    public List<Staff> getStaffs(Long tenantId) {
        return staffRepository.findByTenantId(tenantId);
    }

    public Staff getStaff(Long id) {
        return staffRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("职员不存在"));
    }

    @Transactional
    public Staff createStaff(Long tenantId, Staff staff) {
        staff.setTenantId(tenantId);
        staff.setStatus("active");
        return staffRepository.save(staff);
    }

    @Transactional
    public Staff updateStaff(Long id, Staff staff) {
        Staff existing = staffRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("职员不存在"));

        existing.setName(staff.getName());
        existing.setPhone(staff.getPhone());
        existing.setEmail(staff.getEmail());
        existing.setLevel(staff.getLevel());
        existing.setStatus(staff.getStatus());
        existing.setRemark(staff.getRemark());

        return staffRepository.save(existing);
    }

    @Transactional
    public void deleteStaff(Long id) {
        staffRepository.deleteById(id);
    }

    @Transactional
    public String resetPassword(Long id) {
        Staff staff = staffRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("职员不存在"));
        return "123456";
    }
}
