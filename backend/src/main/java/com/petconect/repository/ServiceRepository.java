package com.petconect.repository;

import com.petconect.model.PetService;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ServiceRepository extends JpaRepository<PetService, Long> {

    List<PetService> findByIsActiveTrue();
    
    List<PetService> findByOwnerIdAndIsActiveTrue(Long ownerId);
    
    List<PetService> findByCategoryAndIsActiveTrue(String category);
    
    @Query("SELECT s FROM PetService s WHERE s.owner.id = :ownerId AND s.isActive = true")
    List<PetService> findActiveServicesByOwner(@Param("ownerId") Long ownerId);
    
    @Query("SELECT s FROM PetService s WHERE s.category = :category AND s.isActive = true")
    List<PetService> findActiveServicesByCategory(@Param("category") String category);
} 