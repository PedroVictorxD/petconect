package com.petconect.controller;

import com.petconect.model.Service;
import com.petconect.model.User;
import com.petconect.service.PetServiceService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/services")
@CrossOrigin(origins = "*")
public class ServiceController {

    @Autowired
    private PetServiceService serviceService;

    @GetMapping
    public ResponseEntity<List<Service>> getAllServices(@RequestParam(required = false) Long ownerId) {
        List<Service> services;
        if (ownerId != null) {
            services = serviceService.getServicesByOwner(ownerId);
        } else {
            services = serviceService.getAllServices();
        }
        return ResponseEntity.ok(services);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Service> getServiceById(@PathVariable Long id) {
        return serviceService.getServiceById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/category/{category}")
    public ResponseEntity<List<Service>> getServicesByCategory(@PathVariable String category) {
        List<Service> services = serviceService.getServicesByCategory(category);
        return ResponseEntity.ok(services);
    }

    @PostMapping
    public ResponseEntity<?> createService(@Valid @RequestBody Service service, Authentication authentication) {
        try {
            User currentUser = (User) authentication.getPrincipal();
            Service createdService = serviceService.createService(service, currentUser.getId());
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Serviço criado com sucesso",
                "service", createdService
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateService(@PathVariable Long id, @Valid @RequestBody Service serviceDetails, Authentication authentication) {
        try {
            User currentUser = (User) authentication.getPrincipal();
            Service updatedService = serviceService.updateService(id, serviceDetails, currentUser.getId());
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Serviço atualizado com sucesso",
                "service", updatedService
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteService(@PathVariable Long id, Authentication authentication) {
        try {
            User currentUser = (User) authentication.getPrincipal();
            serviceService.deleteService(id, currentUser.getId());
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Serviço excluído com sucesso"
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }
} 