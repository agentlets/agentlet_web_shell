# Agentlet Web Shell

> GitHub: [github.com/agentlets/agentlet_web_shell](https://github.com/agentlets/agentlet_web_shell)

**Agentlet Web Shell** is a web application built with **Flutter** that acts as a runtime environment (*shell*) for **Agentlets**, enabling seamless interaction between:

- The **end user**
- A **Large Language Model (LLM)** such as GPT-4, Claude, etc.
- An **Agentlet** (intelligent web component)

This application serves as the central interface for coordinating the bidirectional flow of messages, tools, and data between the different actors in the conversational system.

---

## ✨ Features

- 🖥️ **Web frontend built with Flutter**
- 🤖 **LLM integration (GPT-4, Claude, etc.)**
- 🧩 **Supports running and managing multiple Agentlets**
- 🔁 **Bidirectional flow: User ↔ Shell ↔ LLM ↔ Agentlet**
- 🧠 **Structured tool call handling**
- ⚡ **Support for multiple sessions and conversation flows**

---

## 🚀 What is an Agentlet?

An **Agentlet** is a self-contained *Web Component* that communicates in a structured way with the Shell (this app) and the LLM. This project provides the environment for running these Agentlets, enabling them to interact with users and respond via the language model.

More info: [agentlets/agentlet_lib](https://github.com/agentlets/agentlet_lib)

---

## 📦 Installation and Running

### Requirements

- Flutter 3.19 or higher
- Dart SDK
- Modern browser (Chrome, Edge, Firefox)

### Clone and run locally

```bash
git clone https://github.com/agentlets/agentlet_web_shell.git
cd agentlet_web_shell
flutter pub get
flutter run -d chrome
```

> 🧪 You can also use `flutter build web` for production builds.