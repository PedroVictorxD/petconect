-- Inserir usuários de teste
INSERT INTO users (id, name, email, password, user_type, phone, location, cpf, cnpj, crmv, responsible_name, store_type, operating_hours, security_question, security_answer, is_active, created_at) VALUES
(1, 'Administrador', 'admin@test.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDa', 'ADMINISTRADOR', '(11) 99999-9999', 'São Paulo, SP', '123.456.789-00', NULL, NULL, NULL, NULL, NULL, 'Qual o nome do seu primeiro animal de estimação?', 'Rex', true, CURRENT_TIMESTAMP),
(2, 'João Silva', 'tutor@test.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDa', 'TUTOR', '(11) 88888-8888', 'Rio de Janeiro, RJ', '987.654.321-00', NULL, NULL, NULL, NULL, NULL, 'Qual o nome da sua mãe?', 'Maria', true, CURRENT_TIMESTAMP),
(3, 'Pet Shop Central', 'lojista@test.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDa', 'LOJISTA', '(11) 77777-7777', 'Belo Horizonte, MG', '456.789.123-00', '12.345.678/0001-90', NULL, 'Carlos Silva', 'FISICA', '08:00 às 18:00', 'Qual o nome da cidade onde você nasceu?', 'Belo Horizonte', true, CURRENT_TIMESTAMP),
(4, 'Dr. Maria Santos', 'vet@test.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDa', 'VETERINARIO', '(11) 66666-6666', 'Salvador, BA', '789.123.456-00', NULL, 'BA 1234', NULL, NULL, NULL, 'Qual o nome da sua escola primária?', 'Escola Municipal', true, CURRENT_TIMESTAMP);

-- Inserir produtos de teste
INSERT INTO products (id, name, description, price, stock, category, image_url, owner_id, is_active, created_at) VALUES
(1, 'Ração Premium para Cães', 'Ração de alta qualidade para cães adultos', 89.90, 50, 'Alimentação', 'https://images.unsplash.com/photo-1601758228041-3caa5d9c6c5f?w=400&h=300&fit=crop', 3, true, CURRENT_TIMESTAMP),
(2, 'Brinquedo Interativo', 'Brinquedo para estimular a mente do pet', 45.00, 30, 'Brinquedos', 'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?w=400&h=300&fit=crop', 3, true, CURRENT_TIMESTAMP),
(3, 'Coleira Ajustável', 'Coleira confortável e segura', 35.50, 25, 'Acessórios', 'https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=400&h=300&fit=crop', 3, true, CURRENT_TIMESTAMP),
(4, 'Ração para Gatos', 'Ração especial para gatos adultos', 75.00, 40, 'Alimentação', 'https://images.unsplash.com/photo-1574158622682-e40e69881006?w=400&h=300&fit=crop', 3, true, CURRENT_TIMESTAMP);

-- Inserir serviços de teste
INSERT INTO services (id, name, description, price, category, image_url, owner_id, is_active, created_at) VALUES
(1, 'Consulta Veterinária', 'Consulta geral para pets', 120.00, 'Saúde', 'https://images.unsplash.com/photo-1576201836106-db1758fd1c97?w=400&h=300&fit=crop', 4, true, CURRENT_TIMESTAMP),
(2, 'Vacinação', 'Aplicação de vacinas essenciais', 80.00, 'Saúde', 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=300&fit=crop', 4, true, CURRENT_TIMESTAMP),
(3, 'Banho e Tosa', 'Serviço completo de higiene', 60.00, 'Higiene', 'https://images.unsplash.com/photo-1516734212186-a967f81ad0d7?w=400&h=300&fit=crop', 4, true, CURRENT_TIMESTAMP),
(4, 'Exame de Sangue', 'Exames laboratoriais completos', 150.00, 'Saúde', 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&h=300&fit=crop', 4, true, CURRENT_TIMESTAMP);

-- Inserir pets de teste
INSERT INTO pets (id, name, type, breed, age, weight, image_url, owner_id, is_active, created_at) VALUES
(1, 'Rex', 'CACHORRO', 'Golden Retriever', 3, 25.5, 'https://images.unsplash.com/photo-1552053831-71594a27632d?w=400&h=300&fit=crop', 2, true, CURRENT_TIMESTAMP),
(2, 'Mia', 'GATO', 'Persa', 2, 4.2, 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400&h=300&fit=crop', 2, true, CURRENT_TIMESTAMP),
(3, 'Thor', 'CACHORRO', 'Pastor Alemão', 1, 30.0, 'https://images.unsplash.com/photo-1589941013453-ec89f33b5e95?w=400&h=300&fit=crop', 2, true, CURRENT_TIMESTAMP); 