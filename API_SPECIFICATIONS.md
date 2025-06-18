# 📋 Especificação da API Pet Conect

## 🔗 Base URL
```
http://localhost:8080/api
```

## 🔐 Autenticação
A API utiliza JWT (JSON Web Token) para autenticação. Todos os endpoints protegidos requerem o header:
```
Authorization: Bearer <token>
```

## 📊 Códigos de Resposta
- `200` - Sucesso
- `201` - Criado com sucesso
- `400` - Requisição inválida
- `401` - Não autorizado
- `403` - Proibido
- `404` - Não encontrado
- `500` - Erro interno do servidor

---

## 🔐 Autenticação

### POST /auth/login
**Descrição:** Realiza login do usuário

**Payload:**
```json
{
  "email": "string",
  "password": "string"
}
```

**Resposta de Sucesso (200):**
```json
{
  "success": true,
  "message": "Login realizado com sucesso",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "name": "João Silva",
    "email": "joao@example.com",
    "userType": "TUTOR",
    "phone": "(11) 99999-9999",
    "location": "São Paulo, SP",
    "cpf": "123.456.789-00",
    "isActive": true,
    "createdAt": "2024-01-01T00:00:00Z"
  }
}
```

**Resposta de Erro (400):**
```json
{
  "success": false,
  "message": "Email ou senha incorretos"
}
```

---

### POST /auth/register
**Descrição:** Registra novo usuário

**Payload:**
```json
{
  "name": "string",
  "email": "string",
  "password": "string",
  "userType": "TUTOR|LOJISTA|VETERINARIO",
  "phone": "string",
  "location": "string",
  "cpf": "string",
  "cnpj": "string",
  "crmv": "string",
  "responsibleName": "string",
  "storeType": "VIRTUAL|FISICA",
  "operatingHours": "string",
  "securityQuestion": "string",
  "securityAnswer": "string"
}
```

**Resposta de Sucesso (201):**
```json
{
  "success": true,
  "message": "Usuário cadastrado com sucesso",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 5,
    "name": "Novo Usuário",
    "email": "novo@example.com",
    "userType": "TUTOR",
    "isActive": true,
    "createdAt": "2024-01-01T00:00:00Z"
  }
}
```

---

### POST /auth/forgot-password
**Descrição:** Valida resposta de segurança para recuperação de senha

**Payload:**
```json
{
  "email": "string",
  "securityAnswer": "string"
}
```

**Resposta de Sucesso (200):**
```json
{
  "success": true,
  "message": "Resposta de segurança correta"
}
```

---

### POST /auth/reset-password
**Descrição:** Redefine a senha do usuário

**Payload:**
```json
{
  "email": "string",
  "newPassword": "string"
}
```

**Resposta de Sucesso (200):**
```json
{
  "success": true,
  "message": "Senha redefinida com sucesso"
}
```

---

## 👥 Usuários

### GET /users
**Descrição:** Lista todos os usuários ativos (Apenas ADMIN)

**Headers:**
```
Authorization: Bearer <token>
```

**Resposta de Sucesso (200):**
```json
[
  {
    "id": 1,
    "name": "Administrador",
    "email": "admin@test.com",
    "userType": "ADMINISTRADOR",
    "phone": "(11) 99999-9999",
    "location": "São Paulo, SP",
    "isActive": true,
    "createdAt": "2024-01-01T00:00:00Z"
  }
]
```

---

### GET /users/{id}
**Descrição:** Busca usuário por ID

**Headers:**
```
Authorization: Bearer <token>
```

**Resposta de Sucesso (200):**
```json
{
  "id": 2,
  "name": "João Silva",
  "email": "tutor@test.com",
  "userType": "TUTOR",
  "phone": "(11) 88888-8888",
  "location": "Rio de Janeiro, RJ",
  "cpf": "987.654.321-00",
  "isActive": true,
  "createdAt": "2024-01-02T00:00:00Z"
}
```

---

### GET /users/type/{userType}
**Descrição:** Lista usuários por tipo (Apenas ADMIN)

**Parâmetros:**
- `userType`: TUTOR, LOJISTA, VETERINARIO, ADMINISTRADOR

**Headers:**
```
Authorization: Bearer <token>
```

**Resposta de Sucesso (200):**
```json
[
  {
    "id": 2,
    "name": "João Silva",
    "email": "tutor@test.com",
    "userType": "TUTOR",
    "isActive": true
  }
]
```

---

### PUT /users/{id}
**Descrição:** Atualiza dados do usuário (ADMIN ou próprio usuário)

**Headers:**
```
Authorization: Bearer <token>
```

**Payload:**
```json
{
  "name": "string",
  "email": "string",
  "phone": "string",
  "location": "string",
  "cpf": "string",
  "cnpj": "string",
  "crmv": "string",
  "responsibleName": "string",
  "storeType": "VIRTUAL|FISICA",
  "operatingHours": "string",
  "securityQuestion": "string",
  "securityAnswer": "string"
}
```

**Resposta de Sucesso (200):**
```json
{
  "success": true,
  "message": "Usuário atualizado com sucesso",
  "user": {
    "id": 2,
    "name": "João Silva Atualizado",
    "email": "joao@example.com",
    "userType": "TUTOR",
    "isActive": true
  }
}
```

---

### DELETE /users/{id}
**Descrição:** Desativa usuário (Apenas ADMIN)

**Headers:**
```
Authorization: Bearer <token>
```

**Resposta de Sucesso (200):**
```json
{
  "success": true,
  "message": "Usuário desativado com sucesso"
}
```

---

### POST /users/{id}/activate
**Descrição:** Ativa usuário (Apenas ADMIN)

**Headers:**
```
Authorization: Bearer <token>
```

**Resposta de Sucesso (200):**
```json
{
  "success": true,
  "message": "Usuário ativado com sucesso"
}
```

---

## 🛍️ Produtos

### GET /products
**Descrição:** Lista todos os produtos ativos

**Parâmetros Opcionais:**
- `ownerId`: ID do lojista para filtrar produtos

**Exemplo:**
```
GET /products?ownerId=3
```

**Resposta de Sucesso (200):**
```json
[
  {
    "id": 1,
    "name": "Ração Premium para Cães",
    "description": "Ração de alta qualidade para cães adultos",
    "price": 89.90,
    "stock": 50,
    "category": "Alimentação",
    "imageUrl": "https://images.unsplash.com/photo-1601758228041-3caa5d9c6c5f?w=400&h=300&fit=crop",
    "owner": {
      "id": 3,
      "name": "Pet Shop Central"
    },
    "isActive": true,
    "createdAt": "2024-01-01T00:00:00Z",
    "updatedAt": "2024-01-01T00:00:00Z"
  }
]
```

---

### GET /products/{id}
**Descrição:** Busca produto por ID

**Resposta de Sucesso (200):**
```json
{
  "id": 1,
  "name": "Ração Premium para Cães",
  "description": "Ração de alta qualidade para cães adultos",
  "price": 89.90,
  "stock": 50,
  "category": "Alimentação",
  "imageUrl": "https://images.unsplash.com/photo-1601758228041-3caa5d9c6c5f?w=400&h=300&fit=crop",
  "owner": {
    "id": 3,
    "name": "Pet Shop Central"
  },
  "isActive": true,
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

---

### GET /products/category/{category}
**Descrição:** Lista produtos por categoria

**Resposta de Sucesso (200):**
```json
[
  {
    "id": 1,
    "name": "Ração Premium para Cães",
    "description": "Ração de alta qualidade para cães adultos",
    "price": 89.90,
    "stock": 50,
    "category": "Alimentação",
    "imageUrl": "https://images.unsplash.com/photo-1601758228041-3caa5d9c6c5f?w=400&h=300&fit=crop",
    "owner": {
      "id": 3,
      "name": "Pet Shop Central"
    },
    "isActive": true
  }
]
```

---

### POST /products
**Descrição:** Cria novo produto (Apenas LOJISTA)

**Headers:**
```
Authorization: Bearer <token>
```

**Payload:**
```json
{
  "name": "string",
  "description": "string",
  "price": 0.00,
  "stock": 0,
  "category": "string",
  "imageUrl": "string"
}
```

**Resposta de Sucesso (201):**
```json
{
  "success": true,
  "message": "Produto criado com sucesso",
  "product": {
    "id": 5,
    "name": "Novo Produto",
    "description": "Descrição do produto",
    "price": 45.00,
    "stock": 10,
    "category": "Brinquedos",
    "imageUrl": "https://example.com/image.jpg",
    "owner": {
      "id": 3,
      "name": "Pet Shop Central"
    },
    "isActive": true,
    "createdAt": "2024-01-01T00:00:00Z",
    "updatedAt": "2024-01-01T00:00:00Z"
  }
}
```

---

### PUT /products/{id}
**Descrição:** Atualiza produto (Apenas proprietário)

**Headers:**
```
Authorization: Bearer <token>
```

**Payload:**
```json
{
  "name": "string",
  "description": "string",
  "price": 0.00,
  "stock": 0,
  "category": "string",
  "imageUrl": "string"
}
```

**Resposta de Sucesso (200):**
```json
{
  "success": true,
  "message": "Produto atualizado com sucesso",
  "product": {
    "id": 1,
    "name": "Produto Atualizado",
    "description": "Nova descrição",
    "price": 99.90,
    "stock": 25,
    "category": "Alimentação",
    "imageUrl": "https://example.com/new-image.jpg",
    "owner": {
      "id": 3,
      "name": "Pet Shop Central"
    },
    "isActive": true,
    "updatedAt": "2024-01-01T00:00:00Z"
  }
}
```

---

### DELETE /products/{id}
**Descrição:** Exclui produto (Apenas proprietário)

**Headers:**
```
Authorization: Bearer <token>
```

**Resposta de Sucesso (200):**
```json
{
  "success": true,
  "message": "Produto excluído com sucesso"
}
```

---

### PUT /products/{id}/stock
**Descrição:** Atualiza estoque do produto (Apenas proprietário)

**Headers:**
```
Authorization: Bearer <token>
```

**Payload:**
```json
{
  "stock": 100
}
```

**Resposta de Sucesso (200):**
```json
{
  "success": true,
  "message": "Estoque atualizado com sucesso"
}
```

---

## 🏥 Serviços

### GET /services
**Descrição:** Lista todos os serviços ativos

**Parâmetros Opcionais:**
- `ownerId`: ID do veterinário para filtrar serviços

**Exemplo:**
```
GET /services?ownerId=4
```

**Resposta de Sucesso (200):**
```json
[
  {
    "id": 1,
    "name": "Consulta Veterinária",
    "description": "Consulta geral para pets",
    "price": 120.00,
    "category": "Saúde",
    "imageUrl": "https://images.unsplash.com/photo-1576201836106-db1758fd1c97?w=400&h=300&fit=crop",
    "owner": {
      "id": 4,
      "name": "Dr. Maria Santos"
    },
    "isActive": true,
    "createdAt": "2024-01-01T00:00:00Z",
    "updatedAt": "2024-01-01T00:00:00Z"
  }
]
```

---

### GET /services/{id}
**Descrição:** Busca serviço por ID

**Resposta de Sucesso (200):**
```json
{
  "id": 1,
  "name": "Consulta Veterinária",
  "description": "Consulta geral para pets",
  "price": 120.00,
  "category": "Saúde",
  "imageUrl": "https://images.unsplash.com/photo-1576201836106-db1758fd1c97?w=400&h=300&fit=crop",
  "owner": {
    "id": 4,
    "name": "Dr. Maria Santos"
  },
  "isActive": true,
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

---

### GET /services/category/{category}
**Descrição:** Lista serviços por categoria

**Resposta de Sucesso (200):**
```json
[
  {
    "id": 1,
    "name": "Consulta Veterinária",
    "description": "Consulta geral para pets",
    "price": 120.00,
    "category": "Saúde",
    "imageUrl": "https://images.unsplash.com/photo-1576201836106-db1758fd1c97?w=400&h=300&fit=crop",
    "owner": {
      "id": 4,
      "name": "Dr. Maria Santos"
    },
    "isActive": true
  }
]
```

---

### POST /services
**Descrição:** Cria novo serviço (Apenas VETERINARIO)

**Headers:**
```
Authorization: Bearer <token>
```

**Payload:**
```json
{
  "name": "string",
  "description": "string",
  "price": 0.00,
  "category": "string",
  "imageUrl": "string"
}
```

**Resposta de Sucesso (201):**
```json
{
  "success": true,
  "message": "Serviço criado com sucesso",
  "service": {
    "id": 5,
    "name": "Novo Serviço",
    "description": "Descrição do serviço",
    "price": 150.00,
    "category": "Saúde",
    "imageUrl": "https://example.com/image.jpg",
    "owner": {
      "id": 4,
      "name": "Dr. Maria Santos"
    },
    "isActive": true,
    "createdAt": "2024-01-01T00:00:00Z",
    "updatedAt": "2024-01-01T00:00:00Z"
  }
}
```

---

### PUT /services/{id}
**Descrição:** Atualiza serviço (Apenas proprietário)

**Headers:**
```
Authorization: Bearer <token>
```

**Payload:**
```json
{
  "name": "string",
  "description": "string",
  "price": 0.00,
  "category": "string",
  "imageUrl": "string"
}
```

**Resposta de Sucesso (200):**
```json
{
  "success": true,
  "message": "Serviço atualizado com sucesso",
  "service": {
    "id": 1,
    "name": "Serviço Atualizado",
    "description": "Nova descrição",
    "price": 130.00,
    "category": "Saúde",
    "imageUrl": "https://example.com/new-image.jpg",
    "owner": {
      "id": 4,
      "name": "Dr. Maria Santos"
    },
    "isActive": true,
    "updatedAt": "2024-01-01T00:00:00Z"
  }
}
```

---

### DELETE /services/{id}
**Descrição:** Exclui serviço (Apenas proprietário)

**Headers:**
```
Authorization: Bearer <token>
```

**Resposta de Sucesso (200):**
```json
{
  "success": true,
  "message": "Serviço excluído com sucesso"
}
```

---

## 🐕 Pets

### GET /pets
**Descrição:** Lista todos os pets ativos

**Parâmetros Opcionais:**
- `ownerId`: ID do tutor para filtrar pets

**Exemplo:**
```
GET /pets?ownerId=2
```

**Resposta de Sucesso (200):**
```json
[
  {
    "id": 1,
    "name": "Rex",
    "type": "CACHORRO",
    "breed": "Golden Retriever",
    "age": 3,
    "weight": 25.5,
    "imageUrl": "https://images.unsplash.com/photo-1552053831-71594a27632d?w=400&h=300&fit=crop",
    "owner": {
      "id": 2,
      "name": "João Silva"
    },
    "isActive": true,
    "createdAt": "2024-01-01T00:00:00Z",
    "updatedAt": "2024-01-01T00:00:00Z"
  }
]
```

---

### GET /pets/{id}
**Descrição:** Busca pet por ID

**Resposta de Sucesso (200):**
```json
{
  "id": 1,
  "name": "Rex",
  "type": "CACHORRO",
  "breed": "Golden Retriever",
  "age": 3,
  "weight": 25.5,
  "imageUrl": "https://images.unsplash.com/photo-1552053831-71594a27632d?w=400&h=300&fit=crop",
  "owner": {
    "id": 2,
    "name": "João Silva"
  },
  "isActive": true,
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

---

### GET /pets/type/{type}
**Descrição:** Lista pets por tipo

**Parâmetros:**
- `type`: CACHORRO, GATO, PASSARO, PEIXE, OUTRO

**Resposta de Sucesso (200):**
```json
[
  {
    "id": 1,
    "name": "Rex",
    "type": "CACHORRO",
    "breed": "Golden Retriever",
    "age": 3,
    "weight": 25.5,
    "imageUrl": "https://images.unsplash.com/photo-1552053831-71594a27632d?w=400&h=300&fit=crop",
    "owner": {
      "id": 2,
      "name": "João Silva"
    },
    "isActive": true
  }
]
```

---

### POST /pets
**Descrição:** Cadastra novo pet (Apenas TUTOR)

**Headers:**
```
Authorization: Bearer <token>
```

**Payload:**
```json
{
  "name": "string",
  "type": "CACHORRO|GATO|PASSARO|PEIXE|OUTRO",
  "breed": "string",
  "age": 0,
  "weight": 0.00,
  "imageUrl": "string"
}
```

**Resposta de Sucesso (201):**
```json
{
  "success": true,
  "message": "Pet cadastrado com sucesso",
  "pet": {
    "id": 4,
    "name": "Novo Pet",
    "type": "CACHORRO",
    "breed": "Labrador",
    "age": 2,
    "weight": 20.0,
    "imageUrl": "https://example.com/image.jpg",
    "owner": {
      "id": 2,
      "name": "João Silva"
    },
    "isActive": true,
    "createdAt": "2024-01-01T00:00:00Z",
    "updatedAt": "2024-01-01T00:00:00Z"
  }
}
```

---

### PUT /pets/{id}
**Descrição:** Atualiza pet (Apenas proprietário)

**Headers:**
```
Authorization: Bearer <token>
```

**Payload:**
```json
{
  "name": "string",
  "type": "CACHORRO|GATO|PASSARO|PEIXE|OUTRO",
  "breed": "string",
  "age": 0,
  "weight": 0.00,
  "imageUrl": "string"
}
```

**Resposta de Sucesso (200):**
```json
{
  "success": true,
  "message": "Pet atualizado com sucesso",
  "pet": {
    "id": 1,
    "name": "Rex Atualizado",
    "type": "CACHORRO",
    "breed": "Golden Retriever",
    "age": 4,
    "weight": 26.0,
    "imageUrl": "https://example.com/new-image.jpg",
    "owner": {
      "id": 2,
      "name": "João Silva"
    },
    "isActive": true,
    "updatedAt": "2024-01-01T00:00:00Z"
  }
}
```

---

### DELETE /pets/{id}
**Descrição:** Exclui pet (Apenas proprietário)

**Headers:**
```
Authorization: Bearer <token>
```

**Resposta de Sucesso (200):**
```json
{
  "success": true,
  "message": "Pet excluído com sucesso"
}
```

---

## 🔍 Exemplos de Uso

### Exemplo 1: Login e Listagem de Produtos
```bash
# 1. Login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "lojista@test.com", "password": "123456"}'

# 2. Usar token para listar produtos
curl -X GET http://localhost:8080/api/products \
  -H "Authorization: Bearer <token>"
```

### Exemplo 2: Criar Produto
```bash
curl -X POST http://localhost:8080/api/products \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Brinquedo Novo",
    "description": "Brinquedo interativo para cães",
    "price": 35.00,
    "stock": 20,
    "category": "Brinquedos",
    "imageUrl": "https://example.com/image.jpg"
  }'
```

### Exemplo 3: Atualizar Estoque
```bash
curl -X PUT http://localhost:8080/api/products/1/stock \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"stock": 15}'
```

---

## ⚠️ Validações e Regras de Negócio

### Usuários
- Email deve ser único
- CPF deve ser único (quando fornecido)
- CNPJ deve ser único (quando fornecido)
- CRMV deve ser único (quando fornecido)
- Senha deve ter pelo menos 8 caracteres

### Produtos
- Apenas LOJISTA pode criar produtos
- Apenas proprietário pode editar/excluir
- Preço e estoque devem ser positivos
- Nome é obrigatório

### Serviços
- Apenas VETERINARIO pode criar serviços
- Apenas proprietário pode editar/excluir
- Preço deve ser positivo
- Nome é obrigatório

### Pets
- Apenas TUTOR pode cadastrar pets
- Apenas proprietário pode editar/excluir
- Idade e peso devem ser positivos
- Nome é obrigatório

---

## 🚀 Testando a API

### Usando Postman
1. Importe a coleção de endpoints
2. Configure a variável de ambiente `baseUrl`
3. Faça login e configure a variável `token`
4. Teste os endpoints

### Usando cURL
```bash
# Teste de conectividade
curl -X GET http://localhost:8080/api/products

# Login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@test.com", "password": "123456"}'
```

### Usando Swagger (se implementado)
```
http://localhost:8080/swagger-ui.html
```

---

**Documentação criada para facilitar a integração e desenvolvimento** 📚 