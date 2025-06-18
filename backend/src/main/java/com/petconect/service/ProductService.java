package com.petconect.service;

import com.petconect.model.Product;
import com.petconect.model.User;
import com.petconect.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class ProductService {

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private UserService userService;

    public List<Product> getAllProducts() {
        return productRepository.findByIsActiveTrue();
    }

    public List<Product> getProductsByOwner(Long ownerId) {
        return productRepository.findActiveProductsByOwner(ownerId);
    }

    public List<Product> getProductsByCategory(String category) {
        return productRepository.findActiveProductsByCategory(category);
    }

    public Optional<Product> getProductById(Long id) {
        return productRepository.findById(id);
    }

    public Product createProduct(Product product, Long ownerId) {
        User owner = userService.getUserById(ownerId)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

        // Verificar se o usuário é um lojista
        if (owner.getUserType() != User.UserType.LOJISTA) {
            throw new RuntimeException("Apenas lojistas podem criar produtos");
        }

        product.setOwner(owner);
        return productRepository.save(product);
    }

    public Product updateProduct(Long id, Product productDetails, Long ownerId) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Produto não encontrado"));

        // Verificar se o usuário é o proprietário do produto
        if (!product.getOwner().getId().equals(ownerId)) {
            throw new RuntimeException("Você não tem permissão para editar este produto");
        }

        product.setName(productDetails.getName());
        product.setDescription(productDetails.getDescription());
        product.setPrice(productDetails.getPrice());
        product.setStock(productDetails.getStock());
        product.setCategory(productDetails.getCategory());
        product.setImageUrl(productDetails.getImageUrl());

        return productRepository.save(product);
    }

    public void deleteProduct(Long id, Long ownerId) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Produto não encontrado"));

        // Verificar se o usuário é o proprietário do produto
        if (!product.getOwner().getId().equals(ownerId)) {
            throw new RuntimeException("Você não tem permissão para excluir este produto");
        }

        product.setIsActive(false);
        productRepository.save(product);
    }

    public void updateStock(Long id, Integer newStock, Long ownerId) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Produto não encontrado"));

        // Verificar se o usuário é o proprietário do produto
        if (!product.getOwner().getId().equals(ownerId)) {
            throw new RuntimeException("Você não tem permissão para atualizar este produto");
        }

        if (newStock < 0) {
            throw new RuntimeException("Estoque não pode ser negativo");
        }

        product.setStock(newStock);
        productRepository.save(product);
    }
} 