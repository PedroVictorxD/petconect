package com.petconect.service;

import com.petconect.model.PetService;
import com.petconect.model.User;
import com.petconect.repository.ServiceRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class VetServiceService {

    @Autowired
    private ServiceRepository serviceRepository;

    @Autowired
    private UserService userService;

    public List<PetService> getAllServices() {
        return serviceRepository.findByIsActiveTrue();
    }

    public List<PetService> getServicesByOwner(Long ownerId) {
        return serviceRepository.findActiveServicesByOwner(ownerId);
    }

    public List<PetService> getServicesByCategory(String category) {
        return serviceRepository.findActiveServicesByCategory(category);
    }

    public Optional<PetService> getServiceById(Long id) {
        return serviceRepository.findById(id);
    }

    public PetService createService(PetService service, Long ownerId) {
        User owner = userService.getUserById(ownerId)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

        // Verificar se o usuário é um veterinário
        if (owner.getUserType() != User.UserType.VETERINARIO) {
            throw new RuntimeException("Apenas veterinários podem criar serviços");
        }

        service.setOwner(owner);
        return serviceRepository.save(service);
    }

    public PetService updateService(Long id, PetService serviceDetails, Long ownerId) {
        PetService service = serviceRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Serviço não encontrado"));

        // Verificar se o usuário é o proprietário do serviço
        if (!service.getOwner().getId().equals(ownerId)) {
            throw new RuntimeException("Você não tem permissão para editar este serviço");
        }

        service.setName(serviceDetails.getName());
        service.setDescription(serviceDetails.getDescription());
        service.setPrice(serviceDetails.getPrice());
        service.setCategory(serviceDetails.getCategory());
        service.setImageUrl(serviceDetails.getImageUrl());

        return serviceRepository.save(service);
    }

    public void deleteService(Long id, Long ownerId) {
        PetService service = serviceRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Serviço não encontrado"));

        // Verificar se o usuário é o proprietário do serviço
        if (!service.getOwner().getId().equals(ownerId)) {
            throw new RuntimeException("Você não tem permissão para excluir este serviço");
        }

        service.setIsActive(false);
        serviceRepository.save(service);
    }
} 