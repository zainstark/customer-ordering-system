# Actor Classification — Customer Ordering System

## Purpose

This document identifies and classifies all actors interacting with the Customer Ordering System.

Actors are categorized into:
- Primary Actors
- Supporting Actors
- Offstage Actors

The purpose of this classification is to define:
- system boundaries
- user responsibilities
- external dependencies
- indirect stakeholders affected by the system

---

# Actor Type Definitions

| Actor Type | Definition |
|---|---|
| Primary Actor | An actor that directly interacts with the system to achieve a goal |
| Supporting Actor | An external system or service that assists the system in completing operations |
| Offstage Actor | A stakeholder affected by the system’s behavior but who does not directly interact with this subsystem |

---

# Actor Classification Table

| Actor | Type | Description | Related Use Cases | Rationale |
|---|---|---|---|---|
| Customer | Primary | End user who browses the menu, manages carts, places orders, processes payments, and tracks orders | UC1–UC7 | The customer is the main actor directly interacting with the system |
| External Payment Gateway | Supporting | External payment processor responsible for authorizing and validating transactions | UC5 | The system depends on this external service for secure payment processing |
| Notification Service (Email/SMS Provider) | Supporting | External messaging provider used to deliver confirmations and notifications | UC6 | The system uses this service to communicate with customers |
| Restaurant Staff / Kitchen Staff | Offstage | Staff responsible for preparing and fulfilling confirmed orders | UC4, UC7 | They are affected by orders generated from the system but do not directly use this subsystem |
| Restaurant Management | Offstage | Business stakeholders monitoring operations, orders, and customer activity | Indirectly all | System outputs influence business decisions and operational monitoring |
| System Administrator | Supporting | Maintains deployment environment, availability, monitoring, and security | System-wide | Ensures infrastructure stability and operational continuity |

---

# Actor Interaction Summary

## Customer

The customer is the primary actor of the system.

The customer can:
- register and authenticate
- browse the menu
- manage cart contents
- place orders
- process payments
- track order status

The majority of system functionality exists to support customer operations.

---

## External Payment Gateway

The External Payment Gateway is a supporting actor responsible for:
- payment authorization
- payment validation
- transaction processing

The Customer Ordering System communicates with the payment gateway during UC5 (Process Payment).

Examples:
- Stripe
- PayPal
- Fawry

The gateway exists outside the system boundary.

---

## Notification Service

The Notification Service is a supporting actor used for:
- order confirmations
- payment confirmations
- delivery notifications

The system sends messages through external providers such as:
- Email services
- SMS gateways

This service is external to the application itself.

---

## Restaurant Staff / Kitchen Staff

Restaurant or kitchen staff are offstage actors.

They do not directly interact with the Customer Ordering System, but they are affected by:
- incoming orders
- order status updates
- preparation workflows

Their actions influence order progression indirectly.

---

## Restaurant Management

Restaurant management is considered an offstage actor because management:
- monitors business activity
- evaluates operational performance
- relies on order and payment outcomes

Management is affected by the system but does not directly participate in customer workflows.

---

## System Administrator

The System Administrator supports the operational environment by:
- maintaining servers
- monitoring infrastructure
- handling deployments
- ensuring system availability and security

Although not directly involved in customer operations, administrators are required for reliable system execution.

---

# Actor-to-Use Case Mapping

| Use Case | Primary Actor | Supporting Actor | Offstage Actor |
|---|---|---|---|
| UC1 – Authentication | Customer | — | — |
| UC2 – Browse Menu | Customer | — | — |
| UC3 – Manage Cart | Customer | — | — |
| UC4 – Place Order | Customer | — | Kitchen Staff |
| UC5 – Process Payment | Customer | External Payment Gateway | Restaurant Management |
| UC6 – Send Confirmation | Customer | Notification Service | — |
| UC7 – Track Order | Customer | — | Kitchen Staff |

---

# System Boundary Clarification

The Customer Ordering System includes:
- authentication
- menu browsing
- cart management
- order placement
- payment orchestration
- confirmation delivery
- order tracking

External systems such as:
- payment gateways
- email providers
- SMS providers

exist outside the system boundary and are classified as supporting actors.

Kitchen staff and management are considered offstage actors because they are affected by system operations without directly interacting with this subsystem.

---

# High-Level Actor Diagram

```text
                    +----------------------+
                    |      Customer       |
                    +----------+----------+
                               |
                               v
              +----------------------------------+
              |  Customer Ordering System        |
              +----------------------------------+
                 |              |             |
                 v              v             v
      +----------------+ +----------------+ +------------------+
      | Payment Gateway| | Notification   | | System Admin     |
      |                | | Service        | |                  |
      +----------------+ +----------------+ +------------------+

                 ^
                 |
       +----------------------+
       | Kitchen Staff        |
       | Restaurant Management|
       +----------------------+