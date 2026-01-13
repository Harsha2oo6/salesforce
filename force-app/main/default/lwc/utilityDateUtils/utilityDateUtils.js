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
    // Normalize dateString to ISO format (YYYY-MM-DD)
    // Handle datetime format (YYYY-MM-DD HH:MM:SS) by extracting just the date part
    let datePart = dateString;
    if (dateString.includes(' ')) {
      // It's a datetime string, extract just the date part
      datePart = dateString.split(' ')[0];
    } else if (dateString.includes('T')) {
      // It's an ISO datetime string, extract just the date part
      datePart = dateString.split('T')[0];
    }

    // Validate ISO date format (YYYY-MM-DD)
    if (!/^\d{4}-\d{2}-\d{2}$/.test(datePart)) {
      return 'Invalid date';
    }

    // Parse the date part to ensure it's a valid date
    const date = new Date(datePart + 'T00:00:00');
    if (isNaN(date.getTime())) {
      return 'Invalid date';
    }

    // Verify the parsed date matches the input (handles invalid dates like Feb 30)
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const normalizedDate = `${year}-${month}-${day}`;
    
    if (normalizedDate !== datePart) {
      return 'Invalid date';
    }

    // Check min_date
    if (minDate) {
      const minDateIso = parseDateFromDisplay(minDate, format);
      if (minDateIso && datePart < minDateIso) {
        return `Date must be on or after ${minDate}`;
      }
    }

    // Check max_date
    if (maxDate) {
      const maxDateIso = parseDateFromDisplay(maxDate, format);
      if (maxDateIso && datePart > maxDateIso) {
        return `Date must be on or before ${maxDate}`;
      }
    }

    // Check exclude_dates
    if (excludeDates && Array.isArray(excludeDates) && excludeDates.length > 0) {
      const dateDisplay = formatDateForDisplay(datePart, format);
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

/**
 * Converts datetime string to format expected by lightning-input type="datetime" (ISO format with seconds)
 * @param {string} dateTimeString - DateTime in format YYYY-MM-DD HH:MM:SS or ISO format
 * @returns {string} - DateTime in YYYY-MM-DDTHH:mm:ss format for Salesforce datetime input
 */
export function toLightningDateTimeFormat(dateTimeString) {
  if (!dateTimeString) {
    return '';
  }

  // If already in ISO format (contains T), return as-is
  // Salesforce datetime handles timezone automatically
  if (dateTimeString.includes('T')) {
    return dateTimeString;
  }

  // Convert from storage format (YYYY-MM-DD HH:MM:SS) to ISO format (YYYY-MM-DDTHH:mm:ss)
  return dateTimeString.replace(' ', 'T');
}

/**
 * Parses a datetime string from display format to storage format
 * @param {string} dateTimeString - DateTime in display format (YYYY-MM-DD HH:MM:SS or DD/MM/YYYY HH:MM:SS)
 * @param {string} format - Display format (YYYY-MM-DD HH:MM:SS, DD/MM/YYYY HH:MM:SS)
 * @returns {string} - DateTime in YYYY-MM-DD HH:MM:SS format or empty string if invalid
 */
export function parseDateTimeFromDisplay(dateTimeString, format) {
  if (!dateTimeString || typeof dateTimeString !== 'string') {
    return '';
  }

  try {
    // Handle YYYY-MM-DD HH:MM:SS format
    if (format === 'YYYY-MM-DD HH:MM:SS' || format === 'YYYY-MM-DD HH:mm:ss') {
      const parts = dateTimeString.split(' ');
      if (parts.length === 2) {
        const datePart = parts[0];
        const timePart = parts[1];
        if (/^\d{4}-\d{2}-\d{2}$/.test(datePart) && /^\d{2}:\d{2}:\d{2}$/.test(timePart)) {
          return dateTimeString;
        }
      }
    }

    // Handle DD/MM/YYYY HH:MM:SS format
    if (format === 'DD/MM/YYYY HH:MM:SS' || format === 'DD/MM/YYYY HH:mm:ss') {
      const parts = dateTimeString.split(' ');
      if (parts.length === 2) {
        const datePart = parts[0];
        const timePart = parts[1];
        const dateIso = parseDateFromDisplay(datePart, 'DD/MM/YYYY');
        if (dateIso && /^\d{2}:\d{2}:\d{2}$/.test(timePart)) {
          return `${dateIso} ${timePart}`;
        }
      }
    }

    // Try to parse as Date
    const date = new Date(dateTimeString);
    if (isNaN(date.getTime())) {
      return '';
    }

    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    const seconds = String(date.getSeconds()).padStart(2, '0');

    return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
  } catch (error) {
    console.warn('DateTime parsing error:', error);
    return '';
  }
}

/**
 * Formats a datetime string to display format
 * @param {string} dateTimeString - DateTime in storage format (YYYY-MM-DD HH:MM:SS)
 * @param {string} format - Display format (YYYY-MM-DD HH:MM:SS, DD/MM/YYYY HH:MM:SS)
 * @returns {string} - Formatted datetime string
 */
export function formatDateTimeForDisplay(dateTimeString, format) {
  if (!dateTimeString) {
    return '';
  }

  try {
    let date, time;
    
    // Parse the datetime string
    if (dateTimeString.includes('T')) {
      const [datePart, timePart] = dateTimeString.split('T');
      date = new Date(datePart + 'T' + (timePart || '00:00:00'));
    } else if (dateTimeString.includes(' ')) {
      const [datePart, timePart] = dateTimeString.split(' ');
      date = new Date(datePart + 'T' + (timePart || '00:00:00'));
    } else {
      date = new Date(dateTimeString + 'T00:00:00');
    }

    if (isNaN(date.getTime())) {
      return dateTimeString; // Return original if invalid
    }

    const day = String(date.getDate()).padStart(2, '0');
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const year = date.getFullYear();
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    const seconds = String(date.getSeconds()).padStart(2, '0');

    if (format === 'YYYY-MM-DD HH:MM:SS' || format === 'YYYY-MM-DD HH:mm:ss') {
      return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
    } else if (format === 'DD/MM/YYYY HH:MM:SS' || format === 'DD/MM/YYYY HH:mm:ss') {
      return `${day}/${month}/${year} ${hours}:${minutes}:${seconds}`;
    } else {
      // Default to YYYY-MM-DD HH:MM:SS
      return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
    }
  } catch (error) {
    console.warn('DateTime formatting error:', error);
    return dateTimeString;
  }
}
