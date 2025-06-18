package com.petconect.controller;

import com.petconect.model.User;
import com.petconect.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    @Autowired
    private AuthService authService;

    @PostMapping("/login")
    public ResponseEntity<Map<String, Object>> login(@RequestBody Map<String, String> loginRequest) {
        String email = loginRequest.get("email");
        String password = loginRequest.get("password");

        if (email == null || password == null) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", "Email e senha são obrigatórios"
            ));
        }

        Map<String, Object> result = authService.login(email, password);
        
        if ((Boolean) result.get("success")) {
            return ResponseEntity.ok(result);
        } else {
            return ResponseEntity.badRequest().body(result);
        }
    }

    @PostMapping("/register")
    public ResponseEntity<Map<String, Object>> register(@Valid @RequestBody User user) {
        Map<String, Object> result = authService.register(user);
        
        if ((Boolean) result.get("success")) {
            return ResponseEntity.ok(result);
        } else {
            return ResponseEntity.badRequest().body(result);
        }
    }

    @GetMapping("/security-questions")
    public ResponseEntity<?> getSecurityQuestions(@RequestParam String email) {
        // Chama método público de AuthService para verificar existência
        boolean exists = authService.userExistsByEmail(email);
        if (!exists) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", "Usuário não encontrado"
            ));
        }
        return ResponseEntity.ok(Map.of(
            "success", true,
            "questions", new String[]{
                "Nome do primeiro pet",
                "Nome do primeiro carro",
                "Nome do melhor amigo"
            }
        ));
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<Map<String, Object>> forgotPassword(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        String answerPet = request.get("answerPet");
        String answerCar = request.get("answerCar");
        String answerFriend = request.get("answerFriend");
        String newPassword = request.get("newPassword");
        if (email == null || answerPet == null || answerCar == null || answerFriend == null || newPassword == null) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", "Email, as 3 respostas de segurança e nova senha são obrigatórios"
            ));
        }
        Map<String, Object> result = authService.forgotPassword(email, answerPet, answerCar, answerFriend, newPassword);
        if ((Boolean) result.get("success")) {
            return ResponseEntity.ok(result);
        } else {
            return ResponseEntity.badRequest().body(result);
        }
    }

    @PostMapping("/reset-password")
    public ResponseEntity<Map<String, Object>> resetPassword(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        String newPassword = request.get("newPassword");

        if (email == null || newPassword == null) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", "Email e nova senha são obrigatórios"
            ));
        }

        Map<String, Object> result = authService.resetPassword(email, newPassword);
        
        if ((Boolean) result.get("success")) {
            return ResponseEntity.ok(result);
        } else {
            return ResponseEntity.badRequest().body(result);
        }
    }

    @GetMapping("/forgot-password/question")
    public ResponseEntity<?> getForgotPasswordQuestion(@RequestParam String email) {
        String question = authService.getSecurityQuestionByEmail(email);
        if (question == null) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", "Usuário não encontrado"
            ));
        }
        return ResponseEntity.ok(Map.of(
            "success", true,
            "question", question
        ));
    }
} 