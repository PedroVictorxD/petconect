package com.petconect.service;

import com.petconect.model.User;
import com.petconect.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class UserService implements UserDetailsService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        return userRepository.findByEmailAndIsActiveTrue(email)
                .orElseThrow(() -> new UsernameNotFoundException("Usuário não encontrado: " + email));
    }

    public List<User> getAllUsers() {
        return userRepository.findByIsActiveTrue();
    }

    public List<User> getUsersByType(User.UserType userType) {
        return userRepository.findActiveUsersByType(userType);
    }

    public Optional<User> getUserById(Long id) {
        return userRepository.findById(id);
    }

    public Optional<User> getUserByEmail(String email) {
        return userRepository.findByEmailAndIsActiveTrue(email);
    }

    public User createUser(User user) {
        // Verificar se o email já existe
        if (userRepository.existsByEmail(user.getEmail())) {
            throw new RuntimeException("Email já cadastrado");
        }

        // Verificar CPF único se fornecido
        if (user.getCpf() != null && !user.getCpf().isEmpty() && userRepository.existsByCpf(user.getCpf())) {
            throw new RuntimeException("CPF já cadastrado");
        }

        // Verificar CNPJ único se fornecido
        if (user.getCnpj() != null && !user.getCnpj().isEmpty() && userRepository.existsByCnpj(user.getCnpj())) {
            throw new RuntimeException("CNPJ já cadastrado");
        }

        // Verificar CRMV único se fornecido
        if (user.getCrmv() != null && !user.getCrmv().isEmpty() && userRepository.existsByCrmv(user.getCrmv())) {
            throw new RuntimeException("CRMV já cadastrado");
        }

        // Criptografar senha
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        
        return userRepository.save(user);
    }

    public User updateUser(Long id, User userDetails) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

        // Verificar se o email já existe em outro usuário
        if (!user.getEmail().equals(userDetails.getEmail()) && 
            userRepository.existsByEmail(userDetails.getEmail())) {
            throw new RuntimeException("Email já cadastrado");
        }

        // Verificar CPF único se fornecido
        if (userDetails.getCpf() != null && !userDetails.getCpf().isEmpty() && 
            !userDetails.getCpf().equals(user.getCpf()) && 
            userRepository.existsByCpf(userDetails.getCpf())) {
            throw new RuntimeException("CPF já cadastrado");
        }

        // Verificar CNPJ único se fornecido
        if (userDetails.getCnpj() != null && !userDetails.getCnpj().isEmpty() && 
            !userDetails.getCnpj().equals(user.getCnpj()) && 
            userRepository.existsByCnpj(userDetails.getCnpj())) {
            throw new RuntimeException("CNPJ já cadastrado");
        }

        // Verificar CRMV único se fornecido
        if (userDetails.getCrmv() != null && !userDetails.getCrmv().isEmpty() && 
            !userDetails.getCrmv().equals(user.getCrmv()) && 
            userRepository.existsByCrmv(userDetails.getCrmv())) {
            throw new RuntimeException("CRMV já cadastrado");
        }

        // Atualizar campos
        user.setName(userDetails.getName());
        user.setEmail(userDetails.getEmail());
        user.setPhone(userDetails.getPhone());
        user.setLocation(userDetails.getLocation());
        user.setCpf(userDetails.getCpf());
        user.setCnpj(userDetails.getCnpj());
        user.setCrmv(userDetails.getCrmv());
        user.setResponsibleName(userDetails.getResponsibleName());
        user.setStoreType(userDetails.getStoreType());
        user.setOperatingHours(userDetails.getOperatingHours());
        user.setSecurityAnswerPet(userDetails.getSecurityAnswerPet());
        user.setSecurityAnswerCar(userDetails.getSecurityAnswerCar());
        user.setSecurityAnswerFriend(userDetails.getSecurityAnswerFriend());

        // Se a senha foi fornecida, criptografar
        if (userDetails.getPassword() != null && !userDetails.getPassword().isEmpty()) {
            user.setPassword(passwordEncoder.encode(userDetails.getPassword()));
        }

        return userRepository.save(user);
    }

    public void deleteUser(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));
        user.setIsActive(false);
        userRepository.save(user);
    }

    public void activateUser(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));
        user.setIsActive(true);
        userRepository.save(user);
    }

    public boolean validatePassword(String email, String password) {
        Optional<User> user = userRepository.findByEmailAndIsActiveTrue(email);
        return user.isPresent() && passwordEncoder.matches(password, user.get().getPassword());
    }

    public PasswordEncoder getPasswordEncoder() {
        return passwordEncoder;
    }
} 