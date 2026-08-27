import { LightningElement, api,track } from 'lwc';

export default class Timer extends LightningElement {
	@api timeup;
    @track totalTime = parseInt(this.timeup)  *60; // 3 minutes in seconds
    timer;
    isRunning = false;
    enableResend = false;
	/** Timer Functions **/
	@api
    startTimer() {
		console.log('*** Timer start ***',this.timeup);
        if (!this.isRunning && this.totalTime > 0) {
            this.isRunning = true;
            this.enableResend = false;
            this.timer = setInterval(() => {
                if (this.totalTime > 0) {
                    this.totalTime--;
                } else {
                    this.stopTimer();
                    this.notifyTimeUp(); // Notify parent when time is up
                }
            }, 1000);
        }
    }

	@api
	pauseTimer() {
		//console.log('*** Timer pause ***');
		clearInterval(this.timer);
		this.isRunning = false;
	}

	@api
	stopTimer() {
		//console.log('*** Timer stop ***');
		clearInterval(this.timer);
		this.isRunning = false; 
	}

	@api
	resetTimer() {
		//console.log('*** Timer reset ***');
		clearInterval(this.timer);
		this.totalTime =  parseInt(this.timeup) *60; // Reset to 1 minutes 
		this.isRunning = false;
	}

	notifyTimeUp() {
        this.dispatchEvent(new CustomEvent('timeup', { detail: 'Timer finished' }));
    }

	@api
	get displayTime() {
        const minutes = String(Math.floor(this.totalTime / 60)).padStart(2, '0');
        const seconds = String(this.totalTime % 60).padStart(2, '0');
		//console.log('*** Timer displayTime => ', `${minutes} : ${seconds}` );
        return `${minutes}:${seconds}`;
    }
	
}