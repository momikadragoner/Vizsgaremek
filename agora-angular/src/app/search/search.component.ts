import { Component, OnInit } from '@angular/core';
import {productListLong, tags} from '../model/product'

@Component({
  selector: 'app-search',
  templateUrl: './search.component.html',
  styleUrls: ['./search.component.scss']
})
export class SearchComponent implements OnInit {

  constructor() { }

  tags = tags;

  products = productListLong;

  ngOnInit(): void {
  }

}
