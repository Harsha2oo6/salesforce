/**
 * Utility module for date handling and formatting
 * Manages date formatting, parsing, and constraint validation
 */

/**
 * Formats a date string (ISO format) to display format
 * @param {string} dateString - Date in ISO format (YYYY-MM-DD)
 * @param {string} format - Display format (DD/MM/YYYY, MM/DD/YYYY)
 * @returns {string} - Formatted date string
 */
export function formatDateForDisplay(dateString, format) {
  if (!dateString) {
    return '';
  }

  try {
    const date = new Date(dateString + 'T00:00:00'); // Add time to avoid timezone issues
    if (isNaN(date.getTime())) {
      return dateString; // Return original if invalid
    }

    const day = String(date.getDate()).padStart(2, '0');
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const year = date.getFullYear();

    if (format === 'DD/MM/YYYY') {
      return `${day}/${month}/${year}`;
    } else if (format === 'MM/DD/YYYY') {
      return `${month}/${day}/${year}`;
    } else {
      // Default to DD/MM/YYYY
      return `${day}/${month}/${year}`;
    }
  } catch (error) {
    console.warn('Date formatting error:', error);
    return dateString;
  }
}

/**
 * Parses a display format date string to ISO format
 * @param {string} dateString - Date in display format (DD/MM/YYYY or MM/DD/YYYY)
 * @param {string} format - Display format (DD/MM/YYYY, MM/DD/YYYY)
 * @returns {string} - Date in ISO format (YYYY-MM-DD) or empty string if invalid
 */
export function parseDateFromDisplay(dateString, format) {
  if (!dateString || typeof dateString !== 'string') {
    return '';
  }

  try {
    const parts = dateString.split('/');
    if (parts.length !== 3) {
      return '';
    }

    let day, month, year;

    if (format === 'DD/MM/YYYY') {
      day = parseInt(parts[0], 10);
      month = parseInt(parts[1], 10);
      year = parseInt(parts[2], 10);
    } else if (format === 'MM/DD/YYYY') {
      month = parseInt(parts[0], 10);
      day = parseInt(parts[1], 10);
      year = parseInt(parts[2], 10);
    } else {
      // Default to DD/MM/YYYY
      day = parseInt(parts[0], 10);
      month = parseInt(parts[1], 10);
      year = parseInt(parts[2], 10);
    }

    // Validate date parts
    if (isNaN(day) || isNaN(month) || isNaN(year)) {
      return '';
    }

    const date = new Date(year, month - 1, day);
    if (
      date.getDate() !== day ||
      date.getMonth() !== month - 1 ||
      date.getFullYear() !== year
    ) {
      return ''; // Invalid date
    }

    // Return in ISO format (YYYY-MM-DD)
    return `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
  } catch (error) {
    console.warn('Date parsing error:', error);
    return '';
  }
}

/**
 * Validates date constraints (min_date, max_date, exclude_dates)
 * @param {string} dateString - Date in ISO format (YYYY-MM-DD)
 * @param {string} minDate - Minimum allowed date in display format
 * @param {string} maxDate - Maximum allowed date in display format
 * @param {Array<string>} excludeDates - Array of excluded dates in display format
 * @param {string} format - Display format for min/max/exclude dates
 * @returns {string|null} - Error message if validation fails, null if passes
 */
export function validateDateConstraints(dateString, minDate, maxDate, excludeDates, format) {
  if (!dateString) {
    return null;
  }

  try {
    const date = new Date(dateString + 'T00:00:00');
    if (isNaN(date.getTime())) {
      return 'Invalid date';
    }

    // Check min_date
    if (minDate) {
      const minDateIso = parseDateFromDisplay(minDate, format);
      if (minDateIso && dateString < minDateIso) {
        return `Date must be on or after ${minDate}`;
      }
    }

    // Check max_date
    if (maxDate) {
      const maxDateIso = parseDateFromDisplay(maxDate, format);
      if (maxDateIso && dateString > maxDateIso) {
        return `Date must be on or before ${maxDate}`;
      }
    }

    // Check exclude_dates
    if (excludeDates && Array.isArray(excludeDates) && excludeDates.length > 0) {
      const dateDisplay = formatDateForDisplay(dateString, format);
      if (excludeDates.includes(dateDisplay)) {
        return 'This date is not available';
      }
    }

    return null;
  } catch (error) {
    console.warn('Date constraint validation error:', error);
    return 'Invalid date';
  }
}

/**
 * Converts ISO date to format expected by lightning-input type="date" (YYYY-MM-DD)
 * @param {string} dateString - Date in any format
 * @returns {string} - Date in YYYY-MM-DD format
 */
export function toLightningDateFormat(dateString) {
  if (!dateString) {
    return '';
  }

  // If already in ISO format, return as is
  if (/^\d{4}-\d{2}-\d{2}$/.test(dateString)) {
    return dateString;
  }

  // Try to parse and convert
  const date = new Date(dateString);
  if (isNaN(date.getTime())) {
    return '';
  }

  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');

  return `${year}-${month}-${day}`;
}

