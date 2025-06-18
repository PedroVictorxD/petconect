package com.petconect.controller;

import com.petconect.model.Product;
import com.petconect.model.User;
import com.petconect.service.ProductService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/products")
@CrossOrigin(origins = "*")
public class ProductController {

    @Autowired
    private ProductService productService;

    @GetMapping
    public ResponseEntity<List<Product>> getAllProducts(@RequestParam(required = false) Long ownerId) {
        List<Product> products;
        if (ownerId != null) {
            products = productService.getProductsByOwner(ownerId);
        } else {
            products = productService.getAllProducts();
        }
        return ResponseEntity.ok(products);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Product> getProductById(@PathVariable Long id) {
        return productService.getProductById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/category/{category}")
    public ResponseEntity<List<Product>> getProductsByCategory(@PathVariable String category) {
        List<Product> products = productService.getProductsByCategory(category);
        return ResponseEntity.ok(products);
    }

    @PostMapping
    public ResponseEntity<?> createProduct(@Valid @RequestBody Product product, Authentication authentication) {
        try {
            User currentUser = (User) authentication.getPrincipal();
            Product createdProduct = productService.createProduct(product, currentUser.getId());
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Produto criado com sucesso",
                "product", createdProduct
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateProduct(@PathVariable Long id, @Valid @RequestBody Product productDetails, Authentication authentication) {
        try {
            User currentUser = (User) authentication.getPrincipal();
            Product updatedProduct = productService.updateProduct(id, productDetails, currentUser.getId());
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Produto atualizado com sucesso",
                "product", updatedProduct
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteProduct(@PathVariable Long id, Authentication authentication) {
        try {
            User currentUser = (User) authentication.getPrincipal();
            productService.deleteProduct(id, currentUser.getId());
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Produto excluído com sucesso"
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }

    @PutMapping("/{id}/stock")
    public ResponseEntity<?> updateStock(@PathVariable Long id, @RequestBody Map<String, Integer> request, Authentication authentication) {
        try {
            User currentUser = (User) authentication.getPrincipal();
            Integer newStock = request.get("stock");
            
            if (newStock == null) {
                return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", "Campo 'stock' é obrigatório"
                ));
            }
            
            productService.updateStock(id, newStock, currentUser.getId());
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Estoque atualizado com sucesso"
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }
} 