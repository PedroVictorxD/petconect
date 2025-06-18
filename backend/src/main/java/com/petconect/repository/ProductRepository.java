package com.petconect.repository;

import com.petconect.model.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {

    List<Product> findByIsActiveTrue();
    
    List<Product> findByOwnerIdAndIsActiveTrue(Long ownerId);
    
    List<Product> findByCategoryAndIsActiveTrue(String category);
    
    @Query("SELECT p FROM Product p WHERE p.owner.id = :ownerId AND p.isActive = true")
    List<Product> findActiveProductsByOwner(@Param("ownerId") Long ownerId);
    
    @Query("SELECT p FROM Product p WHERE p.category = :category AND p.isActive = true")
    List<Product> findActiveProductsByCategory(@Param("category") String category);
} 