package com.petconect.service;

import com.petconect.model.Service;
import com.petconect.model.User;
import com.petconect.repository.ServiceRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class PetServiceService {

    @Autowired
    private ServiceRepository serviceRepository;

    @Autowired
    private UserService userService;

    public List<Service> getAllServices() {
        return serviceRepository.findByIsActiveTrue();
    }

    public List<Service> getServicesByOwner(Long ownerId) {
        return serviceRepository.findActiveServicesByOwner(ownerId);
    }

    public List<Service> getServicesByCategory(String category) {
        return serviceRepository.findActiveServicesByCategory(category);
    }

    public Optional<Service> getServiceById(Long id) {
        return serviceRepository.findById(id);
    }

    public Service createService(Service service, Long ownerId) {
        User owner = userService.getUserById(ownerId)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

        // Verificar se o usuário é um veterinário
        if (owner.getUserType() != User.UserType.VETERINARIO) {
            throw new RuntimeException("Apenas veterinários podem criar serviços");
        }

        service.setOwner(owner);
        return serviceRepository.save(service);
    }

    public Service updateService(Long id, Service serviceDetails, Long ownerId) {
        Service service = serviceRepository.findById(id)
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
        Service service = serviceRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Serviço não encontrado"));

        // Verificar se o usuário é o proprietário do serviço
        if (!service.getOwner().getId().equals(ownerId)) {
            throw new RuntimeException("Você não tem permissão para excluir este serviço");
        }

        service.setIsActive(false);
        serviceRepository.save(service);
    }
} 