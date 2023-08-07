import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const handleError = (error) => {
    var errorMessage = '';
    if(error?.body) //logic for all the server error(apex and network). This format contains message value wrapped under body attribute
    {
        if(Array.isArray(error.body)) //if th ebody has array element
        {
            errorMessage += error.body.map(err => err.message).join(',');
        }else if(typeof error.body==='object')
        {
            let serverError = error.body.message;
            let pageError = error.body.pageErrors;
            let duplicateResult = error.body.duplicateResults;
            let fieldErrors = error.body.fieldErrors;
            if(serverError && typeof serverError === 'string') //apex error or exception thrown from server
            {
                errorMessage += serverError;
            }
            if(duplicateResult)
            {
                errorMessage += duplicateResult;
            }
            if(fieldErrors)
            {
                for(let fieldName in fieldErrors)
                {
                    let errorList = fieldErrors[fieldName];
                    for(let i=0; i < errorList.length ; i++)
                    {
                        errorMessage += errorList[i].statuscode + ' ' + fieldName + ' ' + errorList[i].message;
                    }
                }
            }
            if(pageError)
            {
                for(let i=0; i < pageError.length; i++)
                {
                    errorMessage += pageError[i].statuscode + ' ' + pageError[i].message;
                }
            }
        }
    }
    if(error?.message) //JS error
    {
        errorMessage += error.message;
    }
    if(error?.detail) //record edit form or LDS error
    {
        errorMessage += error.statusText;
    }
    return errorMessage;
};
const showToast = (page, variant , title, message, mode = 'dismissable') => {
    const event = new ShowToastEvent({
        title : title,
        message : message,
        mode : mode,
        variant : variant
    });
    page.dispatchEvent(event);
}

export { handleError, showToast}