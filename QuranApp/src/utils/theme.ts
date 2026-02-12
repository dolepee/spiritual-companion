export const Colors = {
  primary: '#2e7d32',
  primaryLight: '#4caf50',
  primaryDark: '#1b5e20',
  secondary: '#f57c00',
  secondaryLight: '#ff9800',
  background: '#f8f9fa',
  surface: '#ffffff',
  text: '#333333',
  textSecondary: '#666666',
  textLight: '#ffffff',
  error: '#d32f2f',
  warning: '#f57c00',
  success: '#388e3c',
  border: '#e0e0e0',
  shadow: '#000000',
};

export const Typography = {
  h1: {
    fontSize: 28,
    fontWeight: 'bold' as const,
    color: Colors.primary,
  },
  h2: {
    fontSize: 24,
    fontWeight: 'bold' as const,
    color: Colors.text,
  },
  h3: {
    fontSize: 20,
    fontWeight: 'bold' as const,
    color: Colors.text,
  },
  body1: {
    fontSize: 16,
    color: Colors.text,
  },
  body2: {
    fontSize: 14,
    color: Colors.textSecondary,
  },
  caption: {
    fontSize: 12,
    color: Colors.textSecondary,
  },
  arabic: {
    fontSize: 18,
    fontWeight: 'bold' as const,
    color: Colors.text,
    textAlign: 'right' as const,
    fontFamily: 'Arial',
  },
};

export const Spacing = {
  xs: 4,
  sm: 8,
  md: 16,
  lg: 24,
  xl: 32,
};

export const BorderRadius = {
  sm: 4,
  md: 8,
  lg: 12,
  xl: 16,
  round: 50,
};

export const Shadow = {
  small: {
    elevation: 2,
    shadowColor: Colors.shadow,
    shadowOffset: {width: 0, height: 1},
    shadowOpacity: 0.2,
    shadowRadius: 2,
  },
  medium: {
    elevation: 4,
    shadowColor: Colors.shadow,
    shadowOffset: {width: 0, height: 2},
    shadowOpacity: 0.25,
    shadowRadius: 4,
  },
  large: {
    elevation: 8,
    shadowColor: Colors.shadow,
    shadowOffset: {width: 0, height: 4},
    shadowOpacity: 0.3,
    shadowRadius: 8,
  },
};