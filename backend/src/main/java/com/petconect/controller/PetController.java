package com.petconect.controller;

import com.petconect.model.Pet;
import com.petconect.model.User;
import com.petconect.service.PetManagementService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/pets")
@CrossOrigin(origins = "*")
public class PetController {

    @Autowired
    private PetManagementService petService;

    @GetMapping
    public ResponseEntity<List<Pet>> getAllPets(@RequestParam(required = false) Long ownerId) {
        List<Pet> pets;
        if (ownerId != null) {
            pets = petService.getPetsByOwner(ownerId);
        } else {
            pets = petService.getAllPets();
        }
        return ResponseEntity.ok(pets);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Pet> getPetById(@PathVariable Long id) {
        return petService.getPetById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/type/{type}")
    public ResponseEntity<List<Pet>> getPetsByType(@PathVariable String type) {
        try {
            Pet.PetType petType = Pet.PetType.valueOf(type.toUpperCase());
            List<Pet> pets = petService.getPetsByType(petType);
            return ResponseEntity.ok(pets);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @PostMapping
    public ResponseEntity<?> createPet(@Valid @RequestBody Pet pet, Authentication authentication) {
        try {
            User currentUser = (User) authentication.getPrincipal();
            Pet createdPet = petService.createPet(pet, currentUser.getId());
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Pet cadastrado com sucesso",
                "pet", createdPet
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updatePet(@PathVariable Long id, @Valid @RequestBody Pet petDetails, Authentication authentication) {
        try {
            User currentUser = (User) authentication.getPrincipal();
            Pet updatedPet = petService.updatePet(id, petDetails, currentUser.getId());
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Pet atualizado com sucesso",
                "pet", updatedPet
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deletePet(@PathVariable Long id, Authentication authentication) {
        try {
            User currentUser = (User) authentication.getPrincipal();
            petService.deletePet(id, currentUser.getId());
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Pet excluído com sucesso"
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }
} 