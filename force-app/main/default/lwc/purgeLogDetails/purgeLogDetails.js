import { LightningElement, track } from 'lwc';
import SVG_LOGO from '@salesforce/resourceUrl/logTraceIcon';
import purgeLogData from '@salesforce/apex/PurgeLogController.purgeLogRecords';
import {showToast, handleError} from 'c/baseLightningWebComponent'
import logTraceCss from '@salesforce/resourceUrl/logTraceCss';
import { loadStyle } from 'lightning/platformResourceLoader'; //script to use the 3rd party css and js loaded on static resource


export default class PurgeLogDetails extends LightningElement {
    svgURL = `${SVG_LOGO}#logTraceLogoId`;
    selectedValue;
    isLoaded;
    @track result = {};
    connectedCallback() {
        loadStyle(this, logTraceCss)
    }
    get options() {
        return [
            { label: '-None-', value: null },
            { label: 'Custom Error Log', value: 'Custom_Log_Error_Utils' },
            { label: 'Batch Error Log', value: 'Batch_Apex_Error_Utils' },
            { label: 'Flow Error Log', value: 'Flow_Error_Logging_Utils' },
            { label: 'Integration Log', value: 'Integration_Logging_Utils' }
        ];
    }

    selectLogType(event)
    {
        this.selectedValue = event.detail.value;
    }

    purgeLogRecords()
    {
        this.isLoaded = true;        
        purgeLogData({ logType: this.selectedValue }).then((result)=>{
                                                            this.result = result;
                                                            console.log(JSON.stringify(result));
                                                            if(this.result?.hasError)
                                                            {
                                                                showToast(this, 'error', 'Error', this.result.message);
                                                            }else
                                                            {
                                                                showToast(this, 'success','Success!!',this.result.message);
                                                            } 
                                                            this.isLoaded = false;
                                                            }).catch((error)=>{
                                                                this.result.hasError = true;
                                                                this.result.message = handleError(error);
                                                                this.isLoaded = false;
                                                                showToast(this, 'error', 'Error', this.result.message);
                                                            });
      
    }
    
}