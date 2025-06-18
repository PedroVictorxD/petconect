package com.petconect.controller;

import com.petconect.model.User;
import com.petconect.service.UserService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UserController {

    @Autowired
    private UserService userService;

    @GetMapping
    public ResponseEntity<List<User>> getAllUsers() {
        List<User> users = userService.getAllUsers();
        // Remover senhas dos usuários
        users.forEach(user -> user.setPassword(null));
        return ResponseEntity.ok(users);
    }

    @GetMapping("/{id}")
    public ResponseEntity<User> getUserById(@PathVariable Long id) {
        return userService.getUserById(id)
                .map(user -> {
                    user.setPassword(null);
                    return ResponseEntity.ok(user);
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/type/{userType}")
    public ResponseEntity<List<User>> getUsersByType(@PathVariable String userType) {
        try {
            User.UserType type = User.UserType.valueOf(userType.toUpperCase());
            List<User> users = userService.getUsersByType(type);
            users.forEach(user -> user.setPassword(null));
            return ResponseEntity.ok(users);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @GetMapping("/profile")
    public ResponseEntity<?> getProfile(Authentication authentication) {
        try {
            User currentUser = (User) authentication.getPrincipal();
            return ResponseEntity.ok(Map.of(
                "success", true,
                "user", currentUser
            ));
        } catch (Exception e) {
            return ResponseEntity.status(403).body(Map.of(
                "success", false,
                "message", "Acesso negado"
            ));
        }
    }

    @PutMapping("/profile")
    public ResponseEntity<?> updateProfile(@Valid @RequestBody User userDetails, Authentication authentication) {
        try {
            User currentUser = (User) authentication.getPrincipal();
            
            // Verificar se o usuário está tentando alterar dados de outro usuário
            if (!currentUser.getId().equals(userDetails.getId())) {
                return ResponseEntity.status(403).body(Map.of(
                    "success", false,
                    "message", "Você só pode alterar seus próprios dados"
                ));
            }
            
            User updatedUser = userService.updateUser(currentUser.getId(), userDetails);
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Perfil atualizado com sucesso",
                "user", updatedUser
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }

    @DeleteMapping("/profile")
    public ResponseEntity<?> deleteProfile(Authentication authentication) {
        try {
            User currentUser = (User) authentication.getPrincipal();
            userService.deleteUser(currentUser.getId());
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Conta excluída com sucesso"
            ));
        } catch (Exception e) {
            return ResponseEntity.status(403).body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateUser(@PathVariable Long id, @Valid @RequestBody User userDetails, Authentication authentication) {
        try {
            User currentUser = (User) authentication.getPrincipal();
            
            // Apenas administradores podem editar outros usuários
            if (!currentUser.getUserType().equals(User.UserType.ADMINISTRADOR) && !currentUser.getId().equals(id)) {
                return ResponseEntity.status(403).body(Map.of(
                    "success", false,
                    "message", "Você não tem permissão para editar este usuário"
                ));
            }

            User updatedUser = userService.updateUser(id, userDetails);
            updatedUser.setPassword(null);
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Usuário atualizado com sucesso",
                "user", updatedUser
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteUser(@PathVariable Long id, Authentication authentication) {
        try {
            User currentUser = (User) authentication.getPrincipal();
            
            // Apenas administradores podem deletar usuários
            if (!currentUser.getUserType().equals(User.UserType.ADMINISTRADOR)) {
                return ResponseEntity.status(403).body(Map.of(
                    "success", false,
                    "message", "Você não tem permissão para deletar usuários"
                ));
            }

            userService.deleteUser(id);
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Usuário desativado com sucesso"
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }

    @PostMapping("/{id}/activate")
    public ResponseEntity<?> activateUser(@PathVariable Long id, Authentication authentication) {
        try {
            User currentUser = (User) authentication.getPrincipal();
            
            // Apenas administradores podem ativar usuários
            if (!currentUser.getUserType().equals(User.UserType.ADMINISTRADOR)) {
                return ResponseEntity.status(403).body(Map.of(
                    "success", false,
                    "message", "Você não tem permissão para ativar usuários"
                ));
            }

            userService.activateUser(id);
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Usuário ativado com sucesso"
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }
} 