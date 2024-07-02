import { getFrameHtmlResponse } from '@coinbase/onchainkit/frame';
import { NextRequest, NextResponse } from 'next/server';
import {
  init,
  validateFramesMessage,
  ValidateFramesMessageInput
} from '@airstack/frames';
import { fromBytes } from "viem";
import { URL } from '../../../config';
import { Errors } from '../../../errors';

init(process.env.AIRSTACK_API_KEY ?? '');

async function getResponse(req: NextRequest): Promise<NextResponse> {
  const body: ValidateFramesMessageInput = await req.json();
  const { isValid, message } = await validateFramesMessage(body);
  if (!isValid) return new NextResponse(Errors.NoValidMessage);

  const action = message?.data?.frameActionBody || undefined;
  
  // deserialize state
  const stateStr: any = fromBytes((action?.state ?? []) as Uint8Array, 'string');
  //?? '{"data":"empty"}';
  let state: any;
  if (stateStr) {
    try {
      state = JSON.parse(decodeURIComponent(stateStr.replace(/\+/g,  " ")));
    } catch (err) {
      console.log(err);
    }
  }
  console.log(state);
  
  const chain = action?.buttonIndex === 1 ? 0 : action?.buttonIndex === 2 ? 1 : 0;
  const targetUrl = `${URL}/api/frame/distribute`;
  
  return new NextResponse(getFrameHtmlResponse({
    buttons: [
      {
        label: 'Ether Ξ',
        target: targetUrl
      },
      {
        label: chain === 1 ? 'Enjoy 🔵️' : 'Degen 🎩️',
        target: targetUrl
      },
      {
        label: chain === 1 ? 'Imagine ‼️' : 'Ham 🍖️',
        target: targetUrl
      }
    ],
    image: {
      src: `${URL}/payment.png`,
      aspectRatio: '1:1'
    },
    postUrl: targetUrl,
    state: {
      amount: state?.amount ?? 1,
      chain
    }
  }));
  
}

export async function POST(req: NextRequest): Promise<Response> {
  return getResponse(req);
}

export const dynamic = 'force-dynamic';
