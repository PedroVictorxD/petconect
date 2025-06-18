package com.petconect.repository;

import com.petconect.model.Pet;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PetRepository extends JpaRepository<Pet, Long> {

    List<Pet> findByIsActiveTrue();
    
    List<Pet> findByOwnerIdAndIsActiveTrue(Long ownerId);
    
    List<Pet> findByTypeAndIsActiveTrue(Pet.PetType type);
    
    @Query("SELECT p FROM Pet p WHERE p.owner.id = :ownerId AND p.isActive = true")
    List<Pet> findActivePetsByOwner(@Param("ownerId") Long ownerId);
    
    @Query("SELECT p FROM Pet p WHERE p.type = :type AND p.isActive = true")
    List<Pet> findActivePetsByType(@Param("type") Pet.PetType type);
} 