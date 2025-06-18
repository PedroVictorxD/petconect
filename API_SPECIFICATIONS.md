# Especificações da API - Pet Conect

## Base URL
```
http://localhost:8080/api
```

## Autenticação
Todas as requisições (exceto login e registro) devem incluir o header:
```
Authorization: Bearer {token}
```

## Endpoints

### 1. Autenticação

#### POST /auth/login
**Request:**
```json
{
  "email": "string",
  "password": "string"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "token": "string",
    "user": {
      "id": 1,
      "name": "string",
      "email": "string",
      "userType": "ADMINISTRADOR|LOJISTA|TUTOR|VETERINARIO",
      "phone": "string",
      "location": "string",
      "cnpj": "string (opcional)",
      "crmv": "string (opcional)",
      "responsibleName": "string (opcional)",
      "storeType": "VIRTUAL|FISICA (opcional)",
      "operatingHours": "string (opcional)",
      "createdAt": "2024-01-01T00:00:00Z",
      "updatedAt": "2024-01-01T00:00:00Z"
    }
  }
}
```

#### POST /auth/register
**Request:**
```json
{
  "name": "string",
  "email": "string",
  "password": "string",
  "userType": "ADMINISTRADOR|LOJISTA|TUTOR|VETERINARIO",
  "phone": "string",
  "location": "string",
  "cpf": "string (obrigatório para TUTOR, VETERINARIO, LOJISTA)",
  "cnpj": "string (opcional para LOJISTA)",
  "crmv": "string (opcional para VETERINARIO)",
  "responsibleName": "string (opcional para LOJISTA)",
  "storeType": "VIRTUAL|FISICA (opcional para LOJISTA)",
  "operatingHours": "string (opcional para LOJISTA)",
  "securityQuestion": "string",
  "securityAnswer": "string"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "token": "string",
    "user": {
      "id": 1,
      "name": "string",
      "email": "string",
      "userType": "string",
      // ... outros campos
    }
  }
}
```

### 2. Produtos

#### GET /products
**Query Parameters:**
- `ownerId` (opcional): Filtrar por proprietário

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "string",
      "description": "string",
      "price": 0.0,
      "imageUrl": "string (opcional)",
      "measurementUnit": "KG|G|L|ML|UNIDADE|PACOTE",
      "ownerId": 1,
      "ownerName": "string",
      "ownerLocation": "string",
      "ownerPhone": "string",
      "createdAt": "2024-01-01T00:00:00Z",
      "updatedAt": "2024-01-01T00:00:00Z"
    }
  ]
}
```

#### POST /products
**Request:**
```json
{
  "name": "string",
  "description": "string",
  "price": 0.0,
  "imageUrl": "string (opcional)",
  "measurementUnit": "KG|G|L|ML|UNIDADE|PACOTE",
  "ownerId": 1
}
```

#### PUT /products/{id}
**Request:** Mesmo formato do POST

#### DELETE /products/{id}

### 3. Serviços

#### GET /services
**Query Parameters:**
- `ownerId` (opcional): Filtrar por proprietário

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "string",
      "description": "string",
      "price": 0.0,
      "ownerId": 1,
      "ownerName": "string",
      "ownerLocation": "string",
      "ownerPhone": "string",
      "ownerCrmv": "string",
      "operatingHours": "string",
      "createdAt": "2024-01-01T00:00:00Z",
      "updatedAt": "2024-01-01T00:00:00Z"
    }
  ]
}
```

#### POST /services
**Request:**
```json
{
  "name": "string",
  "description": "string",
  "price": 0.0,
  "ownerId": 1,
  "ownerCrmv": "string",
  "operatingHours": "string"
}
```

#### PUT /services/{id}
**Request:** Mesmo formato do POST

#### DELETE /services/{id}

### 4. Pets

#### GET /pets
**Query Parameters:**
- `ownerId` (opcional): Filtrar por proprietário

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "string",
      "type": "CACHORRO|GATO|PASSARO|PEIXE|OUTRO",
      "breed": "string",
      "age": 0,
      "weight": 0.0,
      "activityLevel": "BAIXA|MODERADA|ALTA|MUITO_ALTA",
      "ownerId": 1,
      "createdAt": "2024-01-01T00:00:00Z",
      "updatedAt": "2024-01-01T00:00:00Z"
    }
  ]
}
```

#### POST /pets
**Request:**
```json
{
  "name": "string",
  "type": "CACHORRO|GATO|PASSARO|PEIXE|OUTRO",
  "breed": "string",
  "age": 0,
  "weight": 0.0,
  "activityLevel": "BAIXA|MODERADA|ALTA|MUITO_ALTA",
  "ownerId": 1
}
```

#### PUT /pets/{id}
**Request:** Mesmo formato do POST

#### DELETE /pets/{id}

### 5. Usuários

#### GET /users
**Query Parameters:**
- `userType` (opcional): Filtrar por tipo de usuário

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "string",
      "email": "string",
      "userType": "string",
      "phone": "string",
      "location": "string",
      "cnpj": "string (opcional)",
      "crmv": "string (opcional)",
      "responsibleName": "string (opcional)",
      "storeType": "string (opcional)",
      "operatingHours": "string (opcional)",
      "createdAt": "2024-01-01T00:00:00Z",
      "updatedAt": "2024-01-01T00:00:00Z"
    }
  ]
}
```

## Códigos de Status HTTP

- **200**: Sucesso
- **201**: Criado com sucesso
- **400**: Bad Request (dados inválidos)
- **401**: Unauthorized (token inválido ou ausente)
- **403**: Forbidden (sem permissão)
- **404**: Not Found
- **500**: Internal Server Error

## Estrutura de Resposta Padrão

**Sucesso:**
```json
{
  "success": true,
  "data": { ... }
}
```

**Erro:**
```json
{
  "success": false,
  "error": "Mensagem de erro",
  "statusCode": 400
}
```

## Validações

### Usuário
- Email deve ser único
- CPF obrigatório para TUTOR, VETERINARIO, LOJISTA
- CNPJ obrigatório para LOJISTA
- CRMV obrigatório para VETERINARIO
- Senha mínimo 8 caracteres

### Produto
- Nome obrigatório
- Preço deve ser positivo
- Unidade de medida deve ser uma das opções válidas

### Serviço
- Nome obrigatório
- Preço deve ser positivo
- CRMV obrigatório para serviços veterinários

### Pet
- Nome obrigatório
- Tipo deve ser uma das opções válidas
- Idade deve ser positiva
- Peso deve ser positivo

## Segurança

1. **JWT Token**: Implementar autenticação JWT
2. **CORS**: Configurar CORS para permitir requisições do Flutter Web
3. **Validação**: Validar todos os dados de entrada
4. **Sanitização**: Sanitizar dados para prevenir SQL Injection
5. **Rate Limiting**: Implementar rate limiting para prevenir abuso

## Configurações Recomendadas

### application.properties
```properties
# Servidor
server.port=8080
server.servlet.context-path=/api

# CORS
spring.web.cors.allowed-origins=*
spring.web.cors.allowed-methods=GET,POST,PUT,DELETE,OPTIONS
spring.web.cors.allowed-headers=*

# JWT
jwt.secret=sua_chave_secreta_muito_segura
jwt.expiration=86400000

# Banco de dados
spring.datasource.url=jdbc:postgresql://localhost:5432/petconect
spring.datasource.username=postgres
spring.datasource.password=sua_senha
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true

# Upload de arquivos
spring.servlet.multipart.max-file-size=10MB
spring.servlet.multipart.max-request-size=10MB
```

## Dependências Maven Recomendadas

```xml
<dependencies>
    <!-- Spring Boot Starter Web -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    
    <!-- Spring Boot Starter Data JPA -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    
    <!-- Spring Boot Starter Security -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-security</artifactId>
    </dependency>
    
    <!-- Spring Boot Starter Validation -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-validation</artifactId>
    </dependency>
    
    <!-- PostgreSQL Driver -->
    <dependency>
        <groupId>org.postgresql</groupId>
        <artifactId>postgresql</artifactId>
        <scope>runtime</scope>
    </dependency>
    
    <!-- JWT -->
    <dependency>
        <groupId>io.jsonwebtoken</groupId>
        <artifactId>jjwt-api</artifactId>
        <version>0.11.5</version>
    </dependency>
    <dependency>
        <groupId>io.jsonwebtoken</groupId>
        <artifactId>jjwt-impl</artifactId>
        <version>0.11.5</version>
        <scope>runtime</scope>
    </dependency>
    <dependency>
        <groupId>io.jsonwebtoken</groupId>
        <artifactId>jjwt-jackson</artifactId>
        <version>0.11.5</version>
        <scope>runtime</scope>
    </dependency>
    
    <!-- Lombok (opcional) -->
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <optional>true</optional>
    </dependency>
</dependencies>
```

## Estrutura de Pacotes Recomendada

```
com.petconect
├── PetConectApplication.java
├── config/
│   ├── SecurityConfig.java
│   ├── CorsConfig.java
│   └── JwtConfig.java
├── controller/
│   ├── AuthController.java
│   ├── ProductController.java
│   ├── ServiceController.java
│   ├── PetController.java
│   └── UserController.java
├── service/
│   ├── AuthService.java
│   ├── ProductService.java
│   ├── ServiceService.java
│   ├── PetService.java
│   └── UserService.java
├── repository/
│   ├── ProductRepository.java
│   ├── ServiceRepository.java
│   ├── PetRepository.java
│   └── UserRepository.java
├── model/
│   ├── User.java
│   ├── Product.java
│   ├── VetService.java
│   └── Pet.java
├── dto/
│   ├── LoginRequest.java
│   ├── RegisterRequest.java
│   └── ApiResponse.java
└── exception/
    ├── GlobalExceptionHandler.java
    └── CustomException.java
```

## Observações Importantes

1. **Compatibilidade**: O app Flutter já está preparado para receber a API Spring Boot
2. **Dados Demo**: Atualmente o app usa dados demo, mas está configurado para usar a API real
3. **Fallback**: O app tem fallback para dados demo quando a API não está disponível
4. **Testes**: Use os usuários de teste já configurados no app para testar a integração
5. **Imagens**: Para upload de imagens, considere usar um serviço como AWS S3 ou similar
6. **Logs**: Implemente logs adequados para debug e monitoramento 