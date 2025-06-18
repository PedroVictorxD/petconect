package com.petconect.service;

import com.petconect.model.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@Service
public class AuthService {

    @Autowired
    private UserService userService;

    @Autowired
    private JwtService jwtService;

    @Autowired
    private AuthenticationManager authenticationManager;

    public Map<String, Object> login(String email, String password) {
        Map<String, Object> response = new HashMap<>();

        try {
            // Autenticar usuário
            Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(email, password)
            );

            User user = (User) authentication.getPrincipal();
            String token = jwtService.generateToken(user);

            // Remover senha do objeto user antes de retornar
            user.setPassword(null);

            response.put("success", true);
            response.put("message", "Login realizado com sucesso");
            response.put("token", token);
            response.put("user", user);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Email ou senha incorretos");
        }

        return response;
    }

    public Map<String, Object> register(User user) {
        Map<String, Object> response = new HashMap<>();

        try {
            User createdUser = userService.createUser(user);
            
            // Gerar token para o usuário recém-criado
            String token = jwtService.generateToken(createdUser);

            // Remover senha do objeto user antes de retornar
            createdUser.setPassword(null);

            response.put("success", true);
            response.put("message", "Usuário cadastrado com sucesso");
            response.put("token", token);
            response.put("user", createdUser);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", e.getMessage());
        }

        return response;
    }

    public Map<String, Object> forgotPassword(String email, String securityAnswer) {
        Map<String, Object> response = new HashMap<>();

        try {
            User user = userService.getUserByEmail(email)
                    .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

            if (!user.getSecurityAnswer().equals(securityAnswer)) {
                throw new RuntimeException("Resposta de segurança incorreta");
            }

            response.put("success", true);
            response.put("message", "Resposta de segurança correta");

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", e.getMessage());
        }

        return response;
    }

    public Map<String, Object> resetPassword(String email, String newPassword) {
        Map<String, Object> response = new HashMap<>();

        try {
            User user = userService.getUserByEmail(email)
                    .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

            user.setPassword(newPassword);
            userService.updateUser(user.getId(), user);

            response.put("success", true);
            response.put("message", "Senha redefinida com sucesso");

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", e.getMessage());
        }

        return response;
    }
} 