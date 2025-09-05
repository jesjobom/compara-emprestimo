# Blueprint: Loan Comparison App

## Overview

This application is designed to help Brazilian users compare different types of loans offered by various banks. It provides a platform to explore loan options and simulate specific loan scenarios to find the most suitable financial products. The user interface and all text are in Portuguese to cater to the target audience.

## Implemented Style, Design, and Features

This section documents the project's evolution.

### Version 1.0
*   **Project Structure:** Standard Flutter project structure.
*   **Core Navigation:** A `BottomNavigationBar` using `go_router`'s `ShellRoute` to switch between "Explorer" and "Simulator" screens.
*   **Theming:** A modern Material 3 theme with light and dark modes, managed by the `provider` package. The color scheme is based on `Colors.deepPurple`, and typography uses `google_fonts`.
*   **State Management:** `provider` is used for theme management.
*   **Routing:** Declarative navigation handled by the `go_router` package, including nested routes for viewing banks associated with a loan type.
*   **Data Models:** `LoanType` and `Bank` models to structure application data.
*   **API Service:** An `ApiService` class to abstract data fetching, initially with mock data and a simple caching mechanism.
*   **Screens:**
    *   `ExplorerScreen`: Displays a searchable list of loan types.
    *   `BankListScreen`: Displays a sortable list of banks for a selected loan type.
    *   `SimulatorScreen`: A form for users to calculate estimated loan payments.
*   **Localization:** Includes the `intl` package for number and currency formatting, configured for Brazilian Portuguese (`pt_BR`).

## Current Plan: Integrate Real Loan Data (v1.1)

The goal of this iteration is to replace the mock loan data with real data from the Brazilian Central Bank (BCB) API, enhancing the "Explorer" screen's functionality.

### Steps:
1.  **Add HTTP Dependency:** Add the `http` package to `pubspec.yaml` to enable communication with external APIs.
2.  **Update Data Model:** Modify the `LoanType` class in `lib/models.dart` to match the structure of the BCB API response. The new model includes `segment` and `modality` fields, with the `name` being a combination of both.
3.  **Update API Service:** Refactor the `getLoanTypes` method in `lib/api_service.dart` to:
    *   Fetch data from the BCB's `HistoricoTaxaJurosDiario/ParametrosConsulta` endpoint.
    *   Parse the JSON response.
    *   Handle potential duplicate entries by using a `Set`.
    *   Maintain the existing in-memory cache to avoid redundant API calls.
4.  **Verify Integration:** Ensure the `ExplorerScreen` correctly fetches and displays the new data from the BCB API.