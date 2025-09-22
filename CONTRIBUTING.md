# Contributing to ARGO NetCDF Pipeline

We welcome contributions to the ARGO NetCDF Pipeline! This document provides guidelines for contributing to the project.

## Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md).

## How to Contribute

### Reporting Issues

1. **Search existing issues** first to avoid duplicates
2. **Use issue templates** when available
3. **Provide detailed information** including:
   - Python version
   - PostgreSQL version
   - Operating system
   - Error messages and stack traces
   - Steps to reproduce

### Submitting Changes

1. **Fork the repository**
2. **Create a feature branch** from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes** following our coding standards
4. **Add tests** for new functionality
5. **Update documentation** as needed
6. **Commit your changes** with descriptive messages:
   ```bash
   git commit -m "Add: implement new quality control algorithm"
   ```
7. **Push to your fork** and **submit a pull request**

### Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/argo-netCDF-pipeline-conversion.git
cd argo-netCDF-pipeline-conversion

# Install development dependencies
pip install -r requirements-dev.txt

# Install pre-commit hooks
pre-commit install

# Run tests
python -m pytest
```

## Coding Standards

### Python Style

- **PEP 8** compliance
- **Black** for code formatting
- **Flake8** for linting
- **mypy** for type checking
- **Maximum line length**: 88 characters (Black default)

### Code Quality

- **Write tests** for all new functionality
- **Maintain test coverage** above 80%
- **Document functions and classes** with docstrings
- **Use type hints** for function parameters and return values
- **Follow existing patterns** in the codebase

### Commit Messages

Use conventional commit format:

- `feat:` for new features
- `fix:` for bug fixes
- `docs:` for documentation changes
- `test:` for adding tests
- `refactor:` for code refactoring
- `style:` for formatting changes
- `perf:` for performance improvements

Example:
```
feat: add density inversion detection algorithm

- Implement UNESCO equation of state for density calculation
- Add configurable threshold for inversion detection
- Include comprehensive tests for edge cases
- Update documentation with algorithm details
```

## Testing

### Running Tests

```bash
# Run all tests
python -m pytest

# Run with coverage
python -m pytest --cov=src

# Run specific test files
python -m pytest tests/test_quality_control.py

# Run tests in parallel
python -m pytest -n auto
```

### Writing Tests

- **Unit tests** for individual functions
- **Integration tests** for component interactions
- **Mock external dependencies** (database, network)
- **Test edge cases** and error conditions
- **Use descriptive test names**

Example:
```python
def test_spike_detection_identifies_temperature_anomalies():
    """Test that spike detection correctly identifies temperature anomalies."""
    # Arrange
    normal_temps = [20.0, 20.1, 20.2, 20.1, 20.0]
    spike_temps = [20.0, 20.1, 35.0, 20.1, 20.0]  # 35.0 is a spike
    
    # Act
    spikes, count = qc_controller.detect_spikes(spike_temps, pressure, 'TEMP')
    
    # Assert
    assert count == 1
    assert spikes[2] == True  # Spike at index 2
```

## Documentation

### Code Documentation

- **Docstrings** for all public functions and classes
- **Type hints** for parameters and return values
- **Examples** in docstrings when helpful
- **Clear variable names** that explain purpose

### Project Documentation

- **Update README.md** for user-facing changes
- **Update API documentation** for new functions
- **Add examples** for new features
- **Update configuration documentation** for new settings

## Pull Request Process

1. **Update documentation** and tests
2. **Ensure all tests pass** locally
3. **Check code formatting**:
   ```bash
   black src/ tests/
   flake8 src/ tests/
   mypy src/
   ```
4. **Update CHANGELOG.md** if applicable
5. **Request review** from maintainers
6. **Address feedback** and update PR
7. **Squash commits** if requested

### PR Title Format

Use conventional commit format for PR titles:
- `feat: add new quality control algorithm`
- `fix: resolve database connection timeout issue`
- `docs: update installation guide for macOS`

## Release Process

1. **Update version** in `src/__init__.py`
2. **Update CHANGELOG.md** with release notes
3. **Create release tag**: `git tag v1.2.0`
4. **Push tag**: `git push origin v1.2.0`
5. **Create GitHub release** with release notes

## Getting Help

- **Documentation**: Check the `docs/` directory
- **Issues**: Search existing issues or create new ones
- **Discussions**: Use GitHub Discussions for questions
- **Email**: Contact maintainers for security issues

## Recognition

Contributors will be:
- **Listed** in the CONTRIBUTORS.md file
- **Mentioned** in release notes
- **Tagged** in relevant GitHub issues and PRs

Thank you for contributing to the ARGO NetCDF Pipeline! 🌊