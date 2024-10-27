
# Pequi - Environment Management for Flutter White-Label Apps

Pequi is a library designed to simplify environment management for white-label applications built with Flutter. It enables you to manage multiple configurations for different clients or environments seamlessly.

## Features

- Define global settings and specific configurations for each environment.
- Manage multiple environments with ease using a simple `environments.yaml` file.
- Easy integration with your Flutter project, allowing environment-specific assets and configurations.

## Getting Started

### Installation

Add `pequi` to your `pubspec.yaml`:

```yaml
dependencies:
  pequi: ^0.0.1
```

Then run:

```bash
flutter pub get
```

### Usage

To set up Pequi, create an `environments.yaml` file in the root of your project with the following structure:

```yaml
global:
    api: "https://example.com"

environments:
  company:
    config: "company"
    packages:
       ios: "company-package"
       android: "company-package-ios"
  company2:
    config: "company2"
    packages:
       ios: "company2-package"
       android: "company2-package-ios"
```

In addition, create an `environments` folder containing a subfolder named `assets` and any other configuration files needed for your environments.

### Running the Application

To run the application with a specific environment, use the following command:

```bash
dart run pequi -e "environment_name"
```

Replace `"environment_name"` with the desired environment, listed in the configuration file (e.g., `company`).

### Example

```bash
dart run pequi -e "company"
```

This command will load the environment-specific configurations for `company` defined in `environments.yaml`.

## Folder Structure

```
├── environments.yaml
├── environments/
│   ├── company/
│   └── company2/
├── lib/
└── pubspec.yaml
```

## Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
