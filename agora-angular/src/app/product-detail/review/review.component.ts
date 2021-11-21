import { Component, Input, OnChanges, OnInit, Output, SimpleChanges } from '@angular/core';
import { faArrowUp, faArrowDown, faStar } from '@fortawesome/free-solid-svg-icons';
import { EventEmitter } from '@angular/core';
import { animate, style, transition, trigger } from '@angular/animations';
import { ThrowStmt } from '@angular/compiler';

@Component({
  selector: 'app-review',
  templateUrl: './review.component.html',
  styleUrls: ['./review.component.scss'],
  animations: [
    trigger('addUpvote', [
      transition(':increment', [
        style({ transform: 'translateY(-1rem)', backgroundColor: 'transparent' }),
        animate('0.4s',
          style({ transform: 'translateY(0rem)', backgroundColor: '#859C62' }))
      ])
    ]),
    trigger('addDownvote', [
      transition(':decrement', [
        style({ transform: 'translateY(1rem)', backgroundColor: 'transparent' }),
        animate('0.4s',
          style({ transform: 'translateY(0rem)', backgroundColor: '#C26969' }))
      ])
    ])
  ]
})
export class ReviewComponent implements OnChanges {

  faArrowUp = faArrowUp;
  faArrowDown = faArrowDown;
  faStar = faStar;

  public hasUpvoted: boolean = false;
  public hasDownvoted: boolean = false;

  private previousContent:any;

  @Input() content: any;
  @Output() contentChange = new EventEmitter<any>();

  upvote() {
    if ((this.hasDownvoted == false) && (this.hasUpvoted == false)) {
      this.content.points++;
      this.hasUpvoted = true;
      this.hasDownvoted = false;
      console.log("all flase");
    }
    else if (this.hasDownvoted == true) {
      this.content.points += 2;
      this.hasUpvoted = true;
      this.hasDownvoted = false;
      console.log("down");
    }
    else if (this.hasUpvoted == true) {
      this.content.points--;
      this.hasUpvoted = false;
      this.hasDownvoted = false;
      console.log("up");
    }
    this.addContent(this.content);
  }

  downvote() {
    if ((this.hasDownvoted == false) && (this.hasUpvoted == false)) {
      this.content.points--;
      this.hasDownvoted = true;
      this.hasUpvoted = false;
    }
    else if (this.hasUpvoted == true) {
      this.content.points -= 2;
      this.hasUpvoted = false;
      this.hasDownvoted = true;
    }
    else if (this.hasDownvoted == true) {
      this.content.points++;
      this.hasDownvoted = false;
      this.hasUpvoted = false;
    }
    this.addContent(this.content);
  }

  addContent(value: any) {
    this.contentChange.emit(value);
  }

  constructor() {

  }

  ngOnInit(): void {
    
  }

  ngOnChanges(changes: SimpleChanges) {

  }
}
