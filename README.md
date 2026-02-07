# 📘 CheckFlow

CheckFlow é um aplicativo mobile desenvolvido em **Flutter**, focado na **coleta de dados em campo por meio de checklists**, com suporte a **registro fotográfico por item** e **exportação estruturada para desktop**.

---

## ✨ Funcionalidades

Atualmente, o CheckFlow permite:

- Criar e gerenciar **checklists**
- Gerar automaticamente os **itens do checklist** a partir de um template inicial
- Visualizar os itens de cada checklist com **indicador visual de status**
- Anexar **fotos por item**, utilizando:
  - Câmera
  - Galeria
- Exportar os dados coletados em um **arquivo ZIP**

O arquivo ZIP gerado será utilizado pelo **CheckFlow Reports** (aplicação desktop) para processamento, análise e geração de relatórios.

---

## 🧱 Escopo do Projeto

Este repositório contém **exclusivamente o aplicativo mobile** do CheckFlow.

- ❌ Não gera relatórios ou PDFs
- ❌ Não possui sincronização em nuvem
- ❌ Não possui autenticação

Toda a **interpretação dos dados, geração de relatórios e PDFs** será responsabilidade do aplicativo desktop (**CheckFlow Reports**).

O foco aqui é:

> **coleta confiável de dados em campo, offline, com evidências fotográficas.**

---

## 🏗️ Arquitetura

O projeto foi estruturado com foco em **clareza, manutenção e separação de responsabilidades**.

#### 📂 Organização por feature

```text
lib/
├── core/
│   ├── database/         # Drift + SQLite
│   ├── di/               # Providers globais
│   └── services/         # Serviços genéricos (ex: file storage)
│
└── features/
    └── checklists/
        ├── data/         # Repositórios
        ├── state/        # Notifiers (Riverpod)
        ├── presentation/ # Telas
        └── services/     # Serviços específicos da feature
```

---

## 🛠️ Tecnologias Utilizadas

- **Flutter**
- **Dart**
- **Drift (SQLite)**
- **Riverpod**
- **image_picker**
- **path_provider**

---

## 📱 Plataforma

- ✅ Android (inicialmente)
- ⏳ iOS (possivelmente no futuro)

O aplicativo opera **somente em modo portrait**, visando melhor usabilidade em campo.

---

## 📦 Exportação de Dados

O CheckFlow exporta os dados coletados em um **arquivo ZIP**, contendo:

- Estrutura organizada por checklist
- Fotos associadas a cada item
- Metadados necessários para processamento posterior

Esse ZIP é consumido pelo projeto **CheckFlow Reports**, responsável por gerar relatórios finais.

---

## 🎯 Objetivo

Fornecer uma ferramenta:

- simples
- rápida
- confiável
- offline

para **coleta estruturada de dados e evidências em campo**, permitindo análise posterior em ambiente desktop.

