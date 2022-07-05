import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/**
 * Parses response data and throws error if not successful
 * @param res - stringified ResponseData
 * @return parsedRes - parsed ResponseData
 */
function processResponse(res) {
    const parsedRes = JSON.parse(res);
    if (!parsedRes.isSuccess) {
        throw parsedRes.error;
    }
    return parsedRes;
}

/**
 * Extracts error message from input param
 * @param errorParam - string/object/array containing error
 * @return errorMessage - front-end friendly error message
 */
function getErrorMessage(errorParam) {
    let errorMessage = 'Unknown error';

    try {
        switch (typeof errorParam) {
            case 'object':
                if (errorParam.error) {
                    //parsed response data
                    errorMessage = errorParam.error;
                } else {
                    //lds errors
                    errorMessage = this.reduceErrors(errorParam);
                }
                break;
            default:
                errorMessage = errorParam;
        }
    } catch (e) {
        errorMessage = errorParam;
    }

    return errorMessage;
}

/**
 * Shows toast via lightning show toast event
 * @param cmp - reference to lwc component calling this function (pass in this)
 * @param title - toast title
 * @param message - toast message
 * @param variant - toast variant
 * @param mode - toast mode
 */
function showToast(cmp, title, message, variant, mode) {
    cmp.dispatchEvent(new ShowToastEvent({title, message, variant, mode}));
}

/**
 * Shows error toast
 * @param cmp - reference to lwc component calling this function (pass in this)
 * @param error - error message
 */
function showErrorToast(cmp, error) {
    this.showToast(cmp, 'Error!', this.getErrorMessage(error), 'error');
}

/**
 * Shows success toast
 * @param cmp - reference to lwc component calling this function (pass in this)
 * @param message - success message
 */
function showSuccessToast(cmp, message) {
    this.showToast(cmp, 'Success!', message, 'success', 'pester');
}

/**
 * Reduces one or more LDS errors into a string[] of error messages.
 * https://github.com/trailheadapps/lwc-recipes/blob/main/force-app/main/default/lwc/ldsUtils/ldsUtils.js
 * @param {FetchResponse|FetchResponse[]} errors
 * @return {String[]} Error messages
 */
function reduceErrors(errors) {
    if (!Array.isArray(errors)) {
        errors = [errors];
    }

    return (
        errors
        // Remove null/undefined items
        .filter((error) => !!error)
        // Extract an error message
        .map((error) => {
            // UI API read errors
            if (Array.isArray(error.body)) {
                return error.body.map((e) => e.message);
            }
            // Page level errors
            else if (
                error?.body?.pageErrors &&
                error.body.pageErrors.length > 0
            ) {
                return error.body.pageErrors.map((e) => e.message);
            }
            // Field level errors
            else if (
                error?.body?.fieldErrors &&
                Object.keys(error.body.fieldErrors).length > 0
            ) {
                const fieldErrors = [];
                Object.values(error.body.fieldErrors).forEach(
                    (errorArray) => {
                        fieldErrors.push(
                            ...errorArray.map((e) => e.message)
                        );
                    }
                );
                return fieldErrors;
            }
            // UI API DML page level errors
            else if (
                error?.body?.output?.errors &&
                error.body.output.errors.length > 0
            ) {
                return error.body.output.errors.map((e) => e.message);
            }
            // UI API DML field level errors
            else if (
                error?.body?.output?.fieldErrors &&
                Object.keys(error.body.output.fieldErrors).length > 0
            ) {
                const fieldErrors = [];
                Object.values(error.body.output.fieldErrors).forEach(
                    (errorArray) => {
                        fieldErrors.push(
                            ...errorArray.map((e) => e.message)
                        );
                    }
                );
                return fieldErrors;
            }
            // UI API DML, Apex and network errors
            else if (error.body && typeof error.body.message === 'string') {
                return error.body.message;
            }
            // JS errors
            else if (typeof error.message === 'string') {
                return error.message;
            }
            // Unknown error shape so try HTTP status text
            return error.statusText;
        })
        // Flatten
        .reduce((prev, curr) => prev.concat(curr), [])
        // Remove empty strings
        .filter((message) => !!message)
    );
}

export {
    processResponse,
    getErrorMessage,
    showToast,
    showSuccessToast,
    showErrorToast
}