package com.petconect.repository;

import com.petconect.model.Service;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ServiceRepository extends JpaRepository<Service, Long> {

    List<Service> findByIsActiveTrue();
    
    List<Service> findByOwnerIdAndIsActiveTrue(Long ownerId);
    
    List<Service> findByCategoryAndIsActiveTrue(String category);
    
    @Query("SELECT s FROM Service s WHERE s.owner.id = :ownerId AND s.isActive = true")
    List<Service> findActiveServicesByOwner(@Param("ownerId") Long ownerId);
    
    @Query("SELECT s FROM Service s WHERE s.category = :category AND s.isActive = true")
    List<Service> findActiveServicesByCategory(@Param("category") String category);
} 