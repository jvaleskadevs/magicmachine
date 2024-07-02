import { getFrameMetadata } from '@coinbase/onchainkit/frame';
import type { Metadata } from 'next';
import { URL } from './config';

const title = 'Magic Machine';
const description = 'Magic Machine';
const image = `${URL}/intro.png`;
const targetUrl = `${URL}/api/frame/chain`;

const frameMetadata = getFrameMetadata({
  buttons: [
    {
      //action: 'tx',
      label: 'Find art',
      target: targetUrl,
      //postUrl: `${URL}/api/tx-success`
    },
    {
      //action: 'tx',
      label: 'Find art x3',
      target: targetUrl,
      //postUrl: `${URL}/api/tx-success`
    }
  ],
  image: { 
    src: image, 
    aspectRatio: '1:1' 
  },
  postUrl: targetUrl
});

export const metadata: Metadata = {
  title,
  description,
  openGraph: {
    title,
    description,
    images: [image]
  },
  other: { ...frameMetadata }
}

export default function Page() {
  return <><h1>Magic Machine is a Farcaster frame.</h1></>
}
