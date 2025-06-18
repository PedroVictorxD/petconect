package com.petconect.service;

import com.petconect.model.Pet;
import com.petconect.model.User;
import com.petconect.repository.PetRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class PetManagementService {

    @Autowired
    private PetRepository petRepository;

    @Autowired
    private UserService userService;

    public List<Pet> getAllPets() {
        return petRepository.findByIsActiveTrue();
    }

    public List<Pet> getPetsByOwner(Long ownerId) {
        return petRepository.findActivePetsByOwner(ownerId);
    }

    public List<Pet> getPetsByType(Pet.PetType type) {
        return petRepository.findActivePetsByType(type);
    }

    public Optional<Pet> getPetById(Long id) {
        return petRepository.findById(id);
    }

    public Pet createPet(Pet pet, Long ownerId) {
        User owner = userService.getUserById(ownerId)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

        // Verificar se o usuário é um tutor
        if (owner.getUserType() != User.UserType.TUTOR) {
            throw new RuntimeException("Apenas tutores podem cadastrar pets");
        }

        pet.setOwner(owner);
        return petRepository.save(pet);
    }

    public Pet updatePet(Long id, Pet petDetails, Long ownerId) {
        Pet pet = petRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Pet não encontrado"));

        // Verificar se o usuário é o proprietário do pet
        if (!pet.getOwner().getId().equals(ownerId)) {
            throw new RuntimeException("Você não tem permissão para editar este pet");
        }

        pet.setName(petDetails.getName());
        pet.setType(petDetails.getType());
        pet.setBreed(petDetails.getBreed());
        pet.setAge(petDetails.getAge());
        pet.setWeight(petDetails.getWeight());
        pet.setImageUrl(petDetails.getImageUrl());

        return petRepository.save(pet);
    }

    public void deletePet(Long id, Long ownerId) {
        Pet pet = petRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Pet não encontrado"));

        // Verificar se o usuário é o proprietário do pet
        if (!pet.getOwner().getId().equals(ownerId)) {
            throw new RuntimeException("Você não tem permissão para excluir este pet");
        }

        pet.setIsActive(false);
        petRepository.save(pet);
    }
} 