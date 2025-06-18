# 🐾 Pet Conect - Sistema Completo de Gestão Pet

## 📋 Índice
- [Visão Geral](#visão-geral)
- [Arquitetura](#arquitetura)
- [Tecnologias](#tecnologias)
- [Instalação e Configuração](#instalação-e-configuração)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [API Documentation](#api-documentation)
- [Funcionalidades](#funcionalidades)
- [Usuários de Teste](#usuários-de-teste)
- [Deploy](#deploy)
- [Contribuição](#contribuição)

## 🎯 Visão Geral

O **Pet Conect** é um sistema completo de gestão para o ecossistema pet, conectando tutores, veterinários, lojistas e administradores em uma plataforma integrada.

### Tipos de Usuários
- **👨‍💼 Administrador**: Gestão completa do sistema
- **👨‍👩‍👧‍👦 Tutor**: Cadastro e gestão de pets
- **🏥 Veterinário**: Oferecimento de serviços veterinários
- **🛍️ Lojista**: Venda de produtos pet

## 🏗️ Arquitetura

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │  Spring Boot    │    │   PostgreSQL    │
│   (Frontend)    │◄──►│   (Backend)     │◄──►│   (Database)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Camadas da Aplicação
- **Frontend**: Flutter (Mobile/Web)
- **Backend**: Spring Boot (REST API)
- **Database**: PostgreSQL
- **Security**: JWT Authentication
- **CORS**: Configurado para cross-origin

## 🛠️ Tecnologias

### Frontend (Flutter)
- **Framework**: Flutter 3.x
- **State Management**: Provider
- **Navigation**: Go Router
- **HTTP Client**: http package
- **Storage**: Shared Preferences
- **UI**: Material Design 3

### Backend (Spring Boot)
- **Framework**: Spring Boot 3.2.0
- **Security**: Spring Security + JWT
- **Database**: Spring Data JPA
- **Validation**: Bean Validation
- **Database**: PostgreSQL
- **Build Tool**: Maven

### Database
- **SGBD**: PostgreSQL 14+
- **ORM**: Hibernate
- **Migration**: Hibernate DDL Auto

## 🚀 Instalação e Configuração

### Pré-requisitos
- Java 17+
- Flutter 3.x
- PostgreSQL 14+
- Maven 3.6+
- Git

### 1. Clone o Repositório
```bash
git clone <repository-url>
cd petconect
```

### 2. Configuração do Banco de Dados
```sql
-- Conecte ao PostgreSQL
psql -U postgres

-- Crie o banco de dados
CREATE DATABASE petconect;

-- Verifique se foi criado
\l

-- Saia do psql
\q
```

### 3. Configuração do Backend
```bash
cd backend

# Edite o application.yml se necessário
# username: postgres
# password: postgres

# Instale as dependências
mvn clean install

# Execute a aplicação
mvn spring-boot:run
```

### 4. Configuração do Frontend
```bash
cd lib

# Instale as dependências
flutter pub get

# Execute a aplicação
flutter run
```

## 📁 Estrutura do Projeto

```
petconect/
├── backend/                          # API Spring Boot
│   ├── src/main/java/com/petconect/
│   │   ├── config/                   # Configurações
│   │   │   └── SecurityConfig.java
│   │   ├── controller/               # Controllers REST
│   │   │   ├── AuthController.java
│   │   │   ├── UserController.java
│   │   │   ├── ProductController.java
│   │   │   ├── ServiceController.java
│   │   │   └── PetController.java
│   │   ├── model/                    # Entidades JPA
│   │   │   ├── User.java
│   │   │   ├── Product.java
│   │   │   ├── Service.java
│   │   │   └── Pet.java
│   │   ├── repository/               # Repositórios
│   │   │   ├── UserRepository.java
│   │   │   ├── ProductRepository.java
│   │   │   ├── ServiceRepository.java
│   │   │   └── PetRepository.java
│   │   ├── service/                  # Lógica de Negócio
│   │   │   ├── AuthService.java
│   │   │   ├── UserService.java
│   │   │   ├── ProductService.java
│   │   │   ├── PetServiceService.java
│   │   │   ├── PetManagementService.java
│   │   │   └── JwtService.java
│   │   └── security/                 # Segurança
│   │       ├── JwtAuthenticationFilter.java
│   │       └── JwtAuthenticationEntryPoint.java
│   ├── src/main/resources/
│   │   ├── application.yml           # Configurações
│   │   └── data.sql                  # Dados iniciais
│   └── pom.xml                       # Dependências Maven
├── lib/                              # App Flutter
│   ├── main.dart                     # Entry point
│   ├── models/                       # Modelos de dados
│   ├── screens/                      # Telas da aplicação
│   │   ├── auth/                     # Autenticação
│   │   ├── admin/                    # Admin
│   │   ├── tutor/                    # Tutor
│   │   ├── veterinario/              # Veterinário
│   │   └── lojista/                  # Lojista
│   ├── services/                     # Serviços
│   ├── widgets/                      # Widgets reutilizáveis
│   ├── theme/                        # Tema da aplicação
│   └── utils/                        # Utilitários
├── pubspec.yaml                      # Dependências Flutter
└── README.md                         # Documentação
```

## 📚 API Documentation

### Base URL
```
http://localhost:8080/api
```

### Autenticação
Todos os endpoints (exceto `/auth/**`) requerem autenticação JWT:
```
Authorization: Bearer <token>
```

### Endpoints Principais

#### 🔐 Autenticação
| Método | Endpoint | Descrição | Payload |
|--------|----------|-----------|---------|
| POST | `/auth/login` | Login de usuário | `{"email": "string", "password": "string"}` |
| POST | `/auth/register` | Registro de usuário | `User object` |
| POST | `/auth/forgot-password` | Recuperar senha | `{"email": "string", "securityAnswer": "string"}` |
| POST | `/auth/reset-password` | Redefinir senha | `{"email": "string", "newPassword": "string"}` |

#### 👥 Usuários
| Método | Endpoint | Descrição | Permissão |
|--------|----------|-----------|-----------|
| GET | `/users` | Listar usuários | ADMIN |
| GET | `/users/{id}` | Buscar usuário | ALL |
| GET | `/users/type/{userType}` | Usuários por tipo | ADMIN |
| PUT | `/users/{id}` | Atualizar usuário | ADMIN/OWNER |
| DELETE | `/users/{id}` | Desativar usuário | ADMIN |
| POST | `/users/{id}/activate` | Ativar usuário | ADMIN |

#### 🛍️ Produtos
| Método | Endpoint | Descrição | Permissão |
|--------|----------|-----------|-----------|
| GET | `/products` | Listar produtos | ALL |
| GET | `/products?ownerId={id}` | Produtos por lojista | ALL |
| GET | `/products/{id}` | Buscar produto | ALL |
| GET | `/products/category/{category}` | Produtos por categoria | ALL |
| POST | `/products` | Criar produto | LOJISTA |
| PUT | `/products/{id}` | Atualizar produto | OWNER |
| DELETE | `/products/{id}` | Excluir produto | OWNER |
| PUT | `/products/{id}/stock` | Atualizar estoque | OWNER |

#### 🏥 Serviços
| Método | Endpoint | Descrição | Permissão |
|--------|----------|-----------|-----------|
| GET | `/services` | Listar serviços | ALL |
| GET | `/services?ownerId={id}` | Serviços por veterinário | ALL |
| GET | `/services/{id}` | Buscar serviço | ALL |
| GET | `/services/category/{category}` | Serviços por categoria | ALL |
| POST | `/services` | Criar serviço | VETERINARIO |
| PUT | `/services/{id}` | Atualizar serviço | OWNER |
| DELETE | `/services/{id}` | Excluir serviço | OWNER |

#### 🐕 Pets
| Método | Endpoint | Descrição | Permissão |
|--------|----------|-----------|-----------|
| GET | `/pets` | Listar pets | ALL |
| GET | `/pets?ownerId={id}` | Pets por tutor | ALL |
| GET | `/pets/{id}` | Buscar pet | ALL |
| GET | `/pets/type/{type}` | Pets por tipo | ALL |
| POST | `/pets` | Cadastrar pet | TUTOR |
| PUT | `/pets/{id}` | Atualizar pet | OWNER |
| DELETE | `/pets/{id}` | Excluir pet | OWNER |

### Modelos de Dados

#### User
```json
{
  "id": 1,
  "name": "João Silva",
  "email": "joao@example.com",
  "userType": "TUTOR",
  "phone": "(11) 99999-9999",
  "location": "São Paulo, SP",
  "cpf": "123.456.789-00",
  "cnpj": "12.345.678/0001-90",
  "crmv": "SP 1234",
  "responsibleName": "João Silva",
  "storeType": "FISICA",
  "operatingHours": "08:00 às 18:00",
  "securityQuestion": "Qual o nome do seu primeiro animal?",
  "securityAnswer": "Rex",
  "isActive": true,
  "createdAt": "2024-01-01T00:00:00Z"
}
```

#### Product
```json
{
  "id": 1,
  "name": "Ração Premium",
  "description": "Ração de alta qualidade",
  "price": 89.90,
  "stock": 50,
  "category": "Alimentação",
  "imageUrl": "https://example.com/image.jpg",
  "owner": {
    "id": 3,
    "name": "Pet Shop Central"
  },
  "isActive": true,
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

#### Service
```json
{
  "id": 1,
  "name": "Consulta Veterinária",
  "description": "Consulta geral para pets",
  "price": 120.00,
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
```

#### Pet
```json
{
  "id": 1,
  "name": "Rex",
  "type": "CACHORRO",
  "breed": "Golden Retriever",
  "age": 3,
  "weight": 25.5,
  "imageUrl": "https://example.com/image.jpg",
  "owner": {
    "id": 2,
    "name": "João Silva"
  },
  "isActive": true,
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

## 🎯 Funcionalidades

### 👨‍💼 Administrador
- ✅ Gestão completa de usuários
- ✅ Visualização de estatísticas
- ✅ Ativação/desativação de contas
- ✅ Monitoramento do sistema

### 👨‍👩‍👧‍👦 Tutor
- ✅ Cadastro e gestão de pets
- ✅ Visualização de produtos disponíveis
- ✅ Busca por serviços veterinários
- ✅ Calculadora de alimentação
- ✅ Perfil personalizado

### 🏥 Veterinário
- ✅ Cadastro de serviços oferecidos
- ✅ Gestão de agenda
- ✅ Visualização de pets cadastrados
- ✅ Perfil profissional

### 🛍️ Lojista
- ✅ Cadastro de produtos
- ✅ Controle de estoque
- ✅ Gestão de preços
- ✅ Perfil da loja

## 👥 Usuários de Teste

### Credenciais de Acesso
| Tipo | Email | Senha | Descrição |
|------|-------|-------|-----------|
| **Admin** | `admin@test.com` | `123456` | Administrador do sistema |
| **Tutor** | `tutor@test.com` | `123456` | João Silva - Tutor de pets |
| **Lojista** | `lojista@test.com` | `123456` | Pet Shop Central |
| **Veterinário** | `vet@test.com` | `123456` | Dr. Maria Santos |

### Dados de Exemplo
- **4 Usuários** (um de cada tipo)
- **4 Produtos** (do lojista)
- **4 Serviços** (do veterinário)
- **3 Pets** (do tutor)

## 🚀 Deploy

### Backend (Spring Boot)
```bash
# Build do projeto
mvn clean package

# Executar JAR
java -jar target/pet-conect-api-0.0.1-SNAPSHOT.jar
```

### Frontend (Flutter)
```bash
# Build para Web
flutter build web

# Build para Android
flutter build apk

# Build para iOS
flutter build ios
```

### Docker (Opcional)
```dockerfile
# Dockerfile para Backend
FROM openjdk:17-jdk-slim
COPY target/pet-conect-api-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app.jar"]
```

## 🔧 Configurações

### Variáveis de Ambiente
```bash
# Database
DB_URL=jdbc:postgresql://localhost:5432/petconect
DB_USERNAME=postgres
DB_PASSWORD=postgres

# JWT
JWT_SECRET=petconect-secret-key-2024-very-long-and-secure-jwt-secret-key
JWT_EXPIRATION=86400000

# Server
SERVER_PORT=8080
```

### Configurações de Segurança
- JWT Token com expiração de 24 horas
- Senhas criptografadas com BCrypt
- CORS configurado para desenvolvimento
- Validação de permissões por tipo de usuário

## 🐛 Troubleshooting

### Problemas Comuns

#### 1. Erro de Conexão com PostgreSQL
```bash
# Verifique se o PostgreSQL está rodando
sudo systemctl status postgresql

# Verifique as credenciais no application.yml
# Teste a conexão
psql -U postgres -d petconect
```

#### 2. Erro de Porta em Uso
```bash
# Verifique se a porta 8080 está livre
netstat -tulpn | grep :8080

# Mate o processo se necessário
kill -9 <PID>
```

#### 3. Erro de Dependências Flutter
```bash
# Limpe o cache
flutter clean

# Reinstale as dependências
flutter pub get
```

## 📝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

## 📞 Suporte

- **Email**: suporte@petconect.com
- **Documentação**: [Link para documentação completa]
- **Issues**: [Link para issues do GitHub]

---

**Desenvolvido com ❤️ para a comunidade pet** 🐾
