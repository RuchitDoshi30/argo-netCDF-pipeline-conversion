# Quality Control Guide

## Overview

The ARGO pipeline implements comprehensive quality control (QC) algorithms to ensure data reliability and scientific validity. This guide explains the QC methodology, algorithms, and configuration options.

## Quality Control Philosophy

The QC system follows a multi-layered approach:

1. **Physical Limits**: Check against known oceanographic ranges
2. **Statistical Analysis**: Detect outliers and anomalies
3. **Vertical Consistency**: Validate profile structure
4. **Cross-Parameter Validation**: Check parameter relationships
5. **Quality Assessment**: Assign overall quality ratings

## QC Algorithms

### 1. Physical Limits Check

Validates measurements against known oceanographic ranges:

```python
# Default physical limits
TEMP_LIMITS = {"min": -2.5, "max": 40.0}    # °C
PSAL_LIMITS = {"min": 2.0, "max": 42.0}     # PSU
PRES_LIMITS = {"min": 0.0, "max": 11000.0}  # dbar
```

**Implementation:**
- Flags values outside physical limits as "bad"
- Configurable thresholds for different regions
- Immediate rejection of impossible values

### 2. Statistical Outlier Detection

Uses Modified Z-Score method for anomaly detection:

```python
# Modified Z-Score calculation
median_abs_deviation = np.median(np.abs(data - np.median(data)))
modified_z_scores = 0.6745 * (data - np.median(data)) / median_abs_deviation
outliers = np.abs(modified_z_scores) > threshold
```

**Advantages:**
- Robust to outliers in the calculation
- Works well with small sample sizes
- Less sensitive to distribution shape

### 3. Spike Detection

Multiple algorithms to identify measurement spikes:

#### 3.1 Second Difference Method

```python
# Calculate second differences
if len(data) >= 3:
    second_diff = np.abs(data[1:-1] - 0.5 * (data[0:-2] + data[2:]))
    spike_mask = second_diff > spike_threshold
```

#### 3.2 Moving Window Method

```python
# Moving window spike detection
for i in range(window_size//2, len(data) - window_size//2):
    window = data[i-window_size//2:i+window_size//2+1]
    center_value = data[i]
    other_values = np.concatenate([window[:window_size//2], window[window_size//2+1:]])
    
    if np.abs(center_value - np.median(other_values)) > threshold:
        spike_mask[i] = True
```

### 4. Gradient Analysis

Detects unrealistic vertical gradients:

```python
# Calculate vertical gradients
dp = np.diff(pressure)  # Pressure differences
dd = np.diff(data)      # Data differences

# Avoid division by zero
valid_gradient = (dp != 0) & np.isfinite(dp) & np.isfinite(dd)
gradients = np.zeros_like(dp)
gradients[valid_gradient] = dd[valid_gradient] / dp[valid_gradient]

# Flag excessive gradients
anomalous_gradient = np.abs(gradients) > gradient_threshold
```

### 5. Density Inversion Detection

Checks for physically impossible density profiles:

```python
# Calculate seawater density using UNESCO equation
density = calculate_density(temperature, salinity, pressure)

# Sort by pressure and check for inversions
sorted_indices = np.argsort(pressure)
sorted_density = density[sorted_indices]

# Detect inversions (density decreasing with depth)
inversions = np.diff(sorted_density) < -inversion_threshold
```

#### UNESCO Equation of State (Simplified)

```python
def calculate_density(temp, salt, pres):
    # Convert pressure to bars
    p = pres / 10.0
    
    # Pure water density at atmospheric pressure
    rho0 = (999.842594 + 6.793952e-2*temp - 9.095290e-3*temp**2 + 
           1.001685e-4*temp**3 - 1.120083e-6*temp**4 + 6.536332e-9*temp**5)
    
    # Salinity contribution
    A = (8.24493e-1 - 4.0899e-3*temp + 7.6438e-5*temp**2 - 
         8.2467e-7*temp**3 + 5.3875e-9*temp**4)
    B = (-5.72466e-3 + 1.0227e-4*temp - 1.6546e-6*temp**2)
    C = 4.8314e-4
    
    rho_atm = rho0 + A*salt + B*salt**(3/2) + C*salt**2
    
    # Pressure effects (bulk modulus)
    K = calculate_bulk_modulus(temp, salt, p)
    
    # Final density
    density = rho_atm / (1 - p/K)
    return density
```

## Quality Categories

Profiles are assigned quality categories based on QC results:

### Excellent (>90% good data)
- Minimal quality issues
- All critical parameters within normal ranges
- No significant spikes or inversions
- Suitable for all scientific applications

### Good (80-90% good data)
- Minor quality concerns
- Most data within acceptable ranges
- Few outliers or spikes detected
- Suitable for most scientific applications

### Acceptable (70-80% good data)
- Moderate quality issues
- Some data outside normal ranges
- Multiple outliers or anomalies
- Usable with caution for research

### Poor (50-70% good data)
- Significant quality problems
- Many measurements flagged as bad
- Substantial data gaps or anomalies
- Limited scientific utility

### Unusable (<50% good data)
- Major quality failures
- Most data flagged as bad or missing
- Severe anomalies throughout profile
- Not suitable for scientific use

## ARGO Quality Control Flags

The system interprets standard ARGO QC flags:

```python
class QCFlag(Enum):
    NO_QC = '0'        # No quality control performed
    GOOD = '1'         # Good data
    PROBABLY_GOOD = '2' # Probably good data
    PROBABLY_BAD = '3'  # Probably bad data
    BAD = '4'          # Bad data
    CHANGED = '5'      # Value changed
    NOT_USED = '6'     # Not used
    NOT_USED_ALT = '7'  # Not used (alternative)
    ESTIMATED = '8'    # Estimated value
    MISSING = '9'      # Missing value
```

**Flag Interpretation:**
- Flags 1-2: Considered "good" data
- Flags 3-4: Considered "bad" data
- Flags 0, 5-9: Handled based on context

## Configuration Options

### Physical Limits

```json
"TEMP": {
  "min": -2.5,           // Minimum temperature (°C)
  "max": 40.0,           // Maximum temperature (°C)
  "spike_threshold": 5.0, // Spike detection threshold
  "gradient_threshold": 2.0 // Gradient threshold (°C/dbar)
}
```

### Quality Thresholds

```json
"quality_control": {
  "thresholds": {
    "min_good_data_percentage": 70.0,  // Minimum acceptable data percentage
    "max_depth_gap": 500.0,            // Maximum gap between measurements (m)
    "min_profile_length": 5,           // Minimum number of measurements
    "density_inversion_threshold": 0.05 // Density inversion threshold (kg/m³)
  }
}
```

### Regional Adjustments

Different regions may require adjusted thresholds:

```json
// Tropical waters
"TEMP": {"min": 15.0, "max": 35.0}

// Polar waters  
"TEMP": {"min": -2.0, "max": 10.0}

// High-salinity regions
"PSAL": {"min": 30.0, "max": 40.0}
```

## Quality Control Reports

The system generates detailed QC reports:

```python
@dataclass
class QCReport:
    profile_id: str                    # Unique profile identifier
    total_measurements: int            # Total number of measurements
    good_data_percentage: float        # Percentage of good data
    flags_summary: Dict[str, int]      # QC flags distribution
    outliers_removed: int              # Number of outliers detected
    spike_detections: int              # Number of spikes detected
    gradient_anomalies: int            # Number of gradient anomalies
    density_inversions: int            # Number of density inversions
    data_quality: DataQuality          # Overall quality assessment
    issues: List[str]                  # List of quality issues
    metadata: Dict[str, Any]           # Additional metadata
```

### Report Generation

```python
# Generate comprehensive quality report
report = qc_controller.clean_profile_data(profile_data)
print(f"Profile {report.profile_id}:")
print(f"  Quality: {report.data_quality.value}")
print(f"  Good data: {report.good_data_percentage:.1f}%")
print(f"  Issues: {', '.join(report.issues)}")
```

## Best Practices

### 1. Threshold Selection

- **Conservative**: Use strict thresholds for high-quality datasets
- **Permissive**: Use relaxed thresholds for exploratory analysis
- **Regional**: Adjust thresholds based on oceanographic region

### 2. Quality Assessment

- **Multi-parameter**: Consider all parameters together
- **Context-aware**: Account for oceanographic conditions
- **Iterative**: Refine thresholds based on results

### 3. Data Retention

- **Preserve original**: Keep original data alongside QC versions
- **Document changes**: Record all QC decisions and modifications
- **Traceability**: Maintain audit trail of QC processes

### 4. Validation

- **Expert review**: Have oceanographers review QC decisions
- **Comparison**: Compare with other QC systems
- **Statistics**: Monitor QC statistics over time

## Advanced Features

### Custom QC Algorithms

Add custom QC algorithms:

```python
class CustomQualityController(ArgoQualityController):
    def detect_custom_anomaly(self, data, **kwargs):
        # Implement custom QC algorithm
        anomalies = your_custom_algorithm(data)
        return anomalies
```

### Machine Learning QC

Integrate ML-based QC:

```python
# Train ML model on expert-validated data
ml_model = train_qc_model(expert_validated_profiles)

# Apply ML QC to new profiles
ml_flags = ml_model.predict(profile_features)
```

### Real-time QC

Implement real-time quality control:

```python
# Process profiles as they arrive
for new_profile in profile_stream:
    qc_result = qc_controller.quick_qc(new_profile)
    if qc_result.quality == DataQuality.EXCELLENT:
        process_immediately(new_profile)
    else:
        queue_for_detailed_qc(new_profile)
```

## Performance Considerations

### Optimization Strategies

1. **Vectorization**: Use NumPy operations for speed
2. **Caching**: Cache frequently used calculations
3. **Parallel Processing**: Run QC on multiple profiles simultaneously
4. **Early Termination**: Skip detailed QC for obviously bad profiles

### Memory Management

```python
# Process large datasets in chunks
for chunk in chunked_profiles(profile_list, chunk_size=1000):
    qc_results = qc_controller.process_chunk(chunk)
    store_results(qc_results)
    del qc_results  # Free memory
```

## References

1. **ARGO Data Management**: [ARGO Quality Control Manual](https://doi.org/10.13155/33951)
2. **UNESCO**: Algorithms for computation of fundamental properties of seawater
3. **IOC**: Manual and Guides for real-time oceanography
4. **Best Practices**: Ocean data quality control procedures

For implementation details, see the source code in `src/quality_control/`.